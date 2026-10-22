-- sp_registrar Venta

USE ZAPATERIA;

USE ZAPATERIA;
GO -- <-- Este GO separa los lotes y soluciona el error

CREATE OR ALTER PROCEDURE sp_RegistrarVenta
    @Cliente_ID INT,
    @Empleado_ID INT,
    @Tienda_ID INT,
    @Variante_ID INT,
    @Cantidad INT,
    @Precio_Unitario DECIMAL(10,2),
    @Metodo_Pago_ID INT,
    @Referencia_Pago VARCHAR(100)
AS
BEGIN
    -- 1. Iniciar la transacción obligatoria
    BEGIN TRANSACTION;

    -- 2. Validación de regla de negocio (Validar stock)
    IF (SELECT Stock_Actual FROM Inventario WHERE Tienda_ID = @Tienda_ID AND Variante_ID = @Variante_ID) < @Cantidad
    BEGIN
        ROLLBACK TRANSACTION; -- Cancela todo si no hay stock
        RAISERROR('Error: Stock insuficiente en la tienda.', 16, 1);
        RETURN;
    END

    -- 3. Crear la Factura
    INSERT INTO Factura (Cliente_ID, Empleado_ID, Tienda_ID, Total_Venta)
    VALUES (@Cliente_ID, @Empleado_ID, @Tienda_ID, (@Cantidad * @Precio_Unitario));
    
    DECLARE @Factura_ID INT = SCOPE_IDENTITY();

    -- 4. Crear el Detalle de Factura
    INSERT INTO Detalle_Factura (Factura_ID, Variante_ID, Cantidad, Precio_Unitario)
    VALUES (@Factura_ID, @Variante_ID, @Cantidad, @Precio_Unitario);

    -- 5. Descontar el Inventario de la tienda y el global
    UPDATE Inventario 
    SET Stock_Actual = Stock_Actual - @Cantidad 
    WHERE Tienda_ID = @Tienda_ID AND Variante_ID = @Variante_ID;

    UPDATE Producto_Variante 
    SET Existencias = Existencias - @Cantidad 
    WHERE Variante_ID = @Variante_ID;

    -- 6. Registrar el Pago y su relación con la Factura
    INSERT INTO Pago (Metodo_Pago_ID, Monto_Pagado, Referencia_Pago)
    VALUES (@Metodo_Pago_ID, (@Cantidad * @Precio_Unitario), @Referencia_Pago);
    
    DECLARE @Pago_ID INT = SCOPE_IDENTITY();

    INSERT INTO Pago_Factura (Pago_ID, Factura_ID, Monto_Aplicado)
    VALUES (@Pago_ID, @Factura_ID, (@Cantidad * @Precio_Unitario));

    -- 7. Confirmar los cambios si todo fue exitoso
    COMMIT TRANSACTION;
END;
GO


USE ZAPATERIA;
GO

-- ==========================================================
-- 1. EJECUTAR EL PROCEDIMIENTO DE PRUEBA (REGISTRAR VENTA)
-- ==========================================================
EXEC sp_RegistrarVenta 
    @Cliente_ID = 1, 
    @Empleado_ID = 1, 
    @Tienda_ID = 1, 
    @Variante_ID = 1, 
    @Cantidad = 2, 
    @Precio_Unitario = 350.00, 
    @Metodo_Pago_ID = 1, 
    @Referencia_Pago = 'EFECTIVO-001';
GO

-- 2. VERIFICAR LOS REGISTROS EN LAS DIFERENTES TABLAS


-- Ver la Factura creada automáticamente
SELECT TOP 5 * FROM Factura ORDER BY Factura_ID DESC;

-- Ver el Detalle de la Factura
SELECT TOP 5 * FROM Detalle_Factura ORDER BY Detalle_Factura_ID DESC;

-- Verificar que el Inventario de la tienda disminuyó
SELECT TOP 5 * FROM Inventario WHERE Tienda_ID = 1;

-- Verificar que el stock global de la variante disminuyó
SELECT TOP 5 * FROM Producto_Variante WHERE Variante_ID = 1;

-- Ver el Pago registrado y su asociación en la tabla intermedia Pago_Factura
SELECT 
    F.Factura_ID,
    F.Total_Venta,
    P.Monto_Pagado,
    MP.Nombre AS Metodo_Pago,
    P.Referencia_Pago,
    PF.Monto_Aplicado
FROM Factura F
INNER JOIN Pago_Factura PF ON F.Factura_ID = PF.Factura_ID
INNER JOIN Pago P ON PF.Pago_ID = P.Pago_ID
INNER JOIN Metodo_Pago MP ON P.Metodo_Pago_ID = MP.Metodo_Pago_ID
ORDER BY F.Factura_ID DESC;




USE ZAPATERIA;
GO

SELECT 
    F.Factura_ID,
    F.Fecha_Venta,
    C.Nombre + ' ' + C.Apellido AS Cliente,
    E.Nombre + ' ' + E.Apellido AS Empleado,
    T.Nombre_Tienda,
    DF.Cantidad AS Cantidad_Comprada,
    MC.Nombre_Modelo,
    F.Total_Venta,
    MP.Nombre AS Metodo_Pago,
    P.Referencia_Pago
FROM Factura F
INNER JOIN Cliente C ON F.Cliente_ID = C.Cliente_ID
INNER JOIN Empleado E ON F.Empleado_ID = E.Empleado_ID
INNER JOIN Tienda_Oficial T ON F.Tienda_ID = T.Tienda_ID
INNER JOIN Detalle_Factura DF ON F.Factura_ID = DF.Factura_ID
INNER JOIN Producto_Variante PV ON DF.Variante_ID = PV.Variante_ID
INNER JOIN Modelo_Calzado MC ON PV.Modelo_ID = MC.Modelo_ID
INNER JOIN Pago_Factura PF ON F.Factura_ID = PF.Factura_ID
INNER JOIN Pago P ON PF.Pago_ID = P.Pago_ID
INNER JOIN Metodo_Pago MP ON P.Metodo_Pago_ID = MP.Metodo_Pago_ID
ORDER BY F.Factura_ID DESC;
GO

USE ZAPATERIA;
GO

CREATE OR ALTER PROCEDURE sp_RegistrarDevolucion
    @Factura_ID INT,
    @Empleado_ID INT,
    @Variante_ID INT,
    @Cantidad INT,
    @Precio_Unitario DECIMAL(10,2),
    @Motivo VARCHAR(255)
AS
BEGIN
    BEGIN TRANSACTION;

    BEGIN TRY
        -- 1. Obtener la tienda de la factura original
        DECLARE @Tienda_ID INT;
        SELECT @Tienda_ID = Tienda_ID FROM Factura WHERE Factura_ID = @Factura_ID;

        IF @Tienda_ID IS NULL
        BEGIN
            ROLLBACK TRANSACTION;
            RAISERROR('La factura especificada no existe.', 16, 1);
            RETURN;
        END

        -- 2. Registrar la Devolución
        DECLARE @MontoReembolso DECIMAL(10,2) = @Cantidad * @Precio_Unitario;
        
        INSERT INTO Devolucion (Factura_ID, Empleado_ID, Motivo, Monto_Reembolso)
        VALUES (@Factura_ID, @Empleado_ID, @Motivo, @MontoReembolso);

        DECLARE @Devolucion_ID INT = SCOPE_IDENTITY();

        -- 3. Registrar Detalle de Devolución
        INSERT INTO Detalle_Devolucion (Devolucion_ID, Variante_ID, Cantidad, Precio_Unitario)
        VALUES (@Devolucion_ID, @Variante_ID, @Cantidad, @Precio_Unitario);

        -- 4. Reintegrar Stock al Inventario y Producto_Variante
        UPDATE Inventario
        SET Stock_Actual = Stock_Actual + @Cantidad,
            Fecha_Ultima_Actualizacion = GETDATE()
        WHERE Tienda_ID = @Tienda_ID AND Variante_ID = @Variante_ID;

        UPDATE Producto_Variante
        SET Existencias = Existencias + @Cantidad
        WHERE Variante_ID = @Variante_ID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        RAISERROR('Error al procesar la devolución.', 16, 1);
    END CATCH
END;
GO


USE ZAPATERIA;
GO

SELECT 
    D.Devolucion_ID,
    D.Factura_ID,
    D.Fecha_Devolucion,
    C.Nombre + ' ' + C.Apellido AS Cliente,
    E.Nombre + ' ' + E.Apellido AS Empleado_Proceso,
    DD.Cantidad AS Cantidad_Devuelta,
    MC.Nombre_Modelo,
    DD.Precio_Unitario,
    D.Monto_Reembolso,
    D.Motivo
FROM Devolucion D
INNER JOIN Factura F ON D.Factura_ID = F.Factura_ID
INNER JOIN Cliente C ON F.Cliente_ID = C.Cliente_ID
INNER JOIN Empleado E ON D.Empleado_ID = E.Empleado_ID
INNER JOIN Detalle_Devolucion DD ON D.Devolucion_ID = DD.Devolucion_ID
INNER JOIN Producto_Variante PV ON DD.Variante_ID = PV.Variante_ID
INNER JOIN Modelo_Calzado MC ON PV.Modelo_ID = MC.Modelo_ID
ORDER BY D.Devolucion_ID DESC;
GO