CREATE DATABASE ZAPATERIA;

USE	ZAPATERIA;
-- TABLA 1 MARCA
CREATE TABLE Marca (
	Marca_ID INT IDENTITY (1,1) PRIMARY KEY, -- ID DE LA MARCA
	Nombre_Marca VARCHAR (100) NOT NULL UNIQUE -- NOMBRE DE LA MARCA EL UNIQUE ES PARA QUE NO SE DUPLIQUEN
);
-- DATOS AÑADIDOS
INSERT INTO Marca (Nombre_Marca) VALUES 
('Nike'),
('Adidas'),
('Puma'),
('Reebok'),
('Andrea');

INSERT INTO Marca (Nombre_Marca) VALUES
    ('PEPE');

-- el unique sirve para no repetir datos de las marcas
Select * from Marca
Select * from Marca Where Marca_ID = 5
Select * from Marca Where Marca_ID IN (3,5)

-- CREAR TABLA 2 CATEGORIA
CREATE TABLE Categoria(
	Categoria_ID INT IDENTITY (1,1) PRIMARY KEY,-- ID DE LA CATEGORIA 
	Estilo_Zapato Varchar (100) NOT NULL UNIQUE  -- ESTILO O TIPO DE ZAPATO (EJEMPLO . DEPORTIVO, CASUAL)  
);

-- DATOS AÑADIDOS DE EJEMPLO
INSERT INTO Categoria (Estilo_Zapato)Values
('Deportivo'),
('Casual'),
('Formal'),
('Sandalia'),
('Botas');

-- Consultas de prueba
Select * from Categoria;
Select * from Categoria Where Categoria_ID = 3;
Select * from Categoria Where Categoria_ID IN (2,3);

-- CREAR LA TABLA 3 COLOR
CREATE TABLE Color (
	Color_ID INT IDENTITY (1,1) PRIMARY KEY, -- ID DEL COLOR
	Color VARCHAR (50) NOT NULL UNIQUE -- NOMBRE DEL COLOR
);

INSERT INTO Color (Color) VALUES
('Negro'),
('Blanco'),
('Rojo'),
('Azul'),
('Gris');

Select * from Color;
Select * from Color Where Color_ID = 3;
Select * from Color Where Color_ID IN (2,3);

-- CREAR LA TABLA 4 TALLA

CREATE TABLE Talla (
	Talla_ID INT IDENTITY (1,1) PRIMARY KEY, --CREAR LA ID DE TALLA
	Numero_Talla VARCHAR (20) NOT NULL, -- NUMERO DE LA TALLA EJEMPLO  25, 26, 27 en este caso solo trabajamos con tallas mexicanas MX
	Escala VARCHAR (50) NOT NULL   -- ESCALA DE MEDIDA EJEMPLO ES US, MX, EUR ES LA ESCALA DE PIE DEL ZAPATO AHORA SOLO USAMOS MX
);

INSERT INTO Talla (Numero_Talla, Escala) VALUES
('24','MX'),
('25','MX'),
('26','MX'),
('27','MX'),
('28','MX');


-- Consultas de prueba
Select * from Talla;
Select * from Talla Where Talla_ID = 3;
Select * from Talla Where Talla_ID IN (2, 4);


-- CREAR TABLA 5 MODELO_CALZADO
CREATE TABLE Modelo_Calzado (
	Modelo_ID INT IDENTITY (1,1) PRIMARY KEY, -- ID UNICO DEL MODELO
	Nombre_Modelo VARCHAR (100) NOT NULL, --NOMBRE DEL MODELO EJEMPLO AIR FORCE 1 , SUPERSTART
	Descripcion VARCHAR (255) NULL, -- DESCRIPCION O DETALLES DEL MODELO DEL ZAPATO
	Precio_Base DECIMAL (10,2) NOT NULL, -- PRECIO BASE DEL CALZADO
	Marca_ID INT NOT NULL,
	Categoria_ID INT NOT NULL

	-- DEFINICION DE LA RELACION FOREIGN KEYS
	CONSTRAINT FK_Modelo_Marca FOREIGN KEY (Marca_ID) REFERENCES Marca(Marca_ID),  -- CREA UNA LLAMADA MODELO_CALZADO DE LA TABLA MARCA A MARCA ID
	CONSTRAINT FK_Modelo_Categoria FOREIGN KEY (Categoria_ID) REFERENCES Categoria(Categoria_ID)
);

	--DATOS PRUEBA
INSERT INTO Modelo_Calzado (Nombre_Modelo, Descripcion, Precio_Base, Marca_ID, Categoria_ID) VALUES
('Air Force 1','Tenis iconicos de cuero',2200,1,1),
('Ultraboost','Tenis para correr de alta amortiguacion',10000,2,1),
('Suede Classic','Calzado Casual de Gazuma',1800,3,2),
('Sleep','Pantuflaz para el hogar',2000,1,2),
('Rino','botas para lodo reforzado',3400,4,5);

SELECT  
	M.Modelo_ID,
	M.Nombre_Modelo,
	M.Precio_Base,
	MA.Nombre_Marca,
	C.Estilo_zapato
FROM Modelo_Calzado M
INNER JOIN Marca MA ON M.Marca_ID = MA.Marca_ID
INNER JOIN Categoria C ON M.Categoria_ID = C.Categoria_ID
--WHERE M.Modelo_ID = (1);
WHERE M.Modelo_ID IN (2,3,4,5);
--AND M.Precio_Base > 2000.00;

--"Une la tabla Marca (a la que llamamos MA) CON LA CONDICIÓN DE QUE
--el código de marca del zapato (M.Marca_ID) sea IGUAL al código de marca de la tabla de marcas (MA.Marca_ID)."




-- CREAR TABLA 6 PRODUCTO VARIANTE
CREATE TABLE Producto_Variante (
	Variante_ID INT IDENTITY (1,1) PRIMARY KEY, -- DE UNICO DE CADA VARIANTE
	Modelo_ID INT NOT NULL,  -- LLAVE FORANE HACIA MODELO_cALZADO
	Color_ID INT NOT NULL, -- LLAVE FORANEA HACIA COLOR 
	Talla_ID INT NOT NULL, -- LLAVE FORANEA HACIA TALLA
	Existencias INT NOT NULL DEFAULT 0,  -- CANTIDAD DE ZAPATOS EN STOCK

	-- REGLA PARA NO REPETIR MISMA COMBINACION (MODELO + COLOR + TALLA)
	CONSTRAINT UQ_Variante UNIQUE(Modelo_ID, Color_ID, Talla_ID),

	-- RELACIONES CON LAS OTRAS TABLAS
	CONSTRAINT FK_Variante_Modelo FOREIGN KEY (Modelo_ID) REFERENCES Modelo_Calzado(Modelo_ID),
	CONSTRAINT FK_Variante_Color FOREIGN KEY (Color_ID) REFERENCES Color(Color_ID),
	CONSTRAINT FK_Variante_Talla FOREIGN KEY (Talla_ID) REFERENCES Talla(Talla_ID)

);

-- INSERTAR DATO DE PRUEBA

INSERT INTO Producto_Variante (Modelo_ID,Color_ID,Talla_ID,Existencias) VALUES
(1,1,4,20), -- Modelo 1 (Ej. Air Force 1) / Color 1 (Negro) / Talla 3 (26) / Stock: 10
(1,2,3,15), -- Modelo 1 (Air Force 1) / Color 2 (Blanco) / Talla 3 (26) / Stock: 15
(2,1,1,8); -- Modelo 2 (Ultraboost)   / Color 1 (Negro)  / Talla 4 (27) / Stock: 8


SELECT
	PV.Variante_ID,
	M.Nombre_Modelo,
	Ma.Nombre_Marca,
	C.Color,
	T.Numero_Talla AS Talla_MX,
	PV.Existencias,
	M.Precio_Base
FROM Producto_Variante PV
INNER JOIN Modelo_Calzado M ON PV.Modelo_ID = M.Modelo_ID
INNER JOIN Marca Ma ON M.Marca_ID = Ma.Marca_ID
INNER JOIN Talla T ON PV.Talla_ID = T.Talla_ID
INNER JOIN Color C ON PV.Color_ID = C.Color_ID

SELECT
	PV.Variante_ID,
	M.Nombre_Modelo,
	Ma.Nombre_Marca,
	C.Color,
	T.Numero_Talla AS Talla_MX,
	PV.Existencias,
	M.Precio_Base
FROM Producto_Variante PV
INNER JOIN Modelo_Calzado M ON PV.Modelo_ID = M.Modelo_ID
INNER JOIN Marca Ma         ON M.Marca_ID = Ma.Marca_ID
INNER JOIN Talla T          ON PV.Talla_ID = T.Talla_ID
INNER JOIN Color C          ON PV.Color_ID = C.Color_ID; 
-- Sumar 5 unidades a la variante con ID 1
UPDATE Producto_Variante
SET Existencias = Existencias + 5
WHERE Variante_ID = 1
AND Color_ID = 1;


--DATOS A AÑADIR TABLA 7 CLIENTE

CREATE TABLE Cliente (
	Cliente_ID INT IDENTITY (1,1) PRIMARY KEY, -- ID UNICO DEL CLIENTE
	Nombre VARCHAR (50) NOT NULL, -- NOMBRE DEL CLIENTE
	Apellido VARCHAR (50) NOT NULL, -- APELLIDO DEL CLIENTE
	Telefono VARCHAR (20), -- NMERO DEL CLIENTE
	Correo VARCHAR (100), -- CORREO ELECTRONICO
	NIT VARCHAR (20) ,
	Fecha_Registro DATETIME DEFAULT GETDATE() -- FECHA EN QUE SE REGISTRO 2026-10-18 23:09:00.000
);

-- UN INSERT SIN EPECIFICAR LA FECHA 
INSERT INTO Cliente (Nombre,Apellido,Telefono,Correo,NIT) VALUES
('Juan','Pérez','5555-5555','Juan@email.com','123456-7');


Select * FROM Cliente;
-- FECHA ESPECIFICA
INSERT INTO Cliente (Nombre, Apellido, Telefono, Correo, NIT, Fecha_Registro)
VALUES ('María', 'Gómez', '4444-4444', 'maria@email.com', '765432-1', '2025-01-15 10:30:00');

-- TABLA EMPLEADO 8

CREATE TABLE Empleado (
	Empleado_ID INT IDENTITY (1,1) PRIMARY KEY, -- ID UNICO EMPLEADO
	Nombre VARCHAR (50) NOT NULL, -- NOMBRE DEL EMPLEADO
	Apellido VARCHAR (50) NOT NULL, -- APELLIDO DEL EMPLEADO
	Puesto VARCHAR (50) NOT NULL, -- PUESTO EJEMPLO VENDEDOR CAJA ADMINISTRADOR
	Telefono VARCHAR (20) NOT NULL, -- TELEFONO DEL EMPLEADO
	Correo VARCHAR (100) NOT NULL, -- CORREO ELECTRONICO 
	Fecha_Contratacion DATE DEFAULT GETDATE(), -- FECHA QUE INGRESO EL EMPLEADO
	Activo_Bit BIT DEFAULT 1    -- 1 = activo / 0 = INACTIVO
);


-- INSERTAR EMPLEADOS DE PRUEBA
INSERT INTO Empleado (Nombre, Apellido, Puesto, Telefono, Correo) 
VALUES 
('Carlos', 'López', 'Vendedor', '5555-0101', 'carlos.lopez@zapateria.com'),
('Ana', 'Martínez', 'Cajera', '5555-0102', 'ana.martinez@zapateria.com');

-- CONSULTAR LA TABLA DE EMPLEADOS
SELECT * FROM Empleado;

-- CREAR TABLA 9 PROVEEDOR
CREATE TABLE Proveedor (
	Proveedor_ID INT IDENTITY (1,1) PRIMARY KEY, -- ID UNICO DEL PROVEEDOR
	Nombre_Empresa VARCHAR (100) NOT NULL, -- NOMBRE DE LA EMPRESA DEL PROVEEDORA
	Nombre_Contacto VARCHAR (100),  -- NOMBRE DE LA PERSONA DE CONTACTO
	Telefono VARCHAR (20), -- TELEFONO DE CONTACTO
	Correo VARCHAR (100), -- CORREO ELECTRONICO
	Direccion VARCHAR (255) -- DIRECCION DE LA EMPRESA
);

-- INSERTAR PROVEEDORES DE PRUEBA
INSERT INTO Proveedor (Nombre_Empresa, Nombre_Contacto, Telefono, Correo, Direccion) 
VALUES 
('Distribuidora de Calzado S.A.', 'Roberto Gómez', '2222-3333', 'contacto@distribuidoracalzado.com', 'Zona 4, Ciudad de Guatemala'),
('Importadora Deportiva S.R.L.', 'Lucía Méndez', '4444-5555', 'ventas@importadoradeportiva.com', 'Zona 9, Ciudad de Guatemala');

-- CONSULTAR LA TABLA DE PROVEEDORES
SELECT * FROM Proveedor;

-- CREAR TABLA 10 TIENDA_OFICIAL
CREATE TABLE Tienda_Oficial (
    Tienda_ID INT IDENTITY (1,1) PRIMARY KEY, -- ID ÚNICO DE LA TIENDA
    Nombre_Tienda VARCHAR(100) NOT NULL,       -- NOMBRE O SUCURSAL DE LA TIENDA
    Direccion VARCHAR(255) NOT NULL,           -- DIRECCIÓN FÍSICA
    Telefono VARCHAR(20)                       -- TELÉFONO DE CONTACTO DE LA SUCURSAL
);

-- INSERTAR TIENDAS DE PRUEBA
INSERT INTO Tienda_Oficial (Nombre_Tienda, Direccion, Telefono) 
VALUES 
('Tienda Central Retalhuleu', 'Zona 1, Retalhuleu', '7771-0001'),
('Sucursal Coatepeque', 'Centro Comercial La Trinidad, Coatepeque', '7772-0002');

-- CONSULTAR LA TABLA DE TIENDAS
SELECT * FROM Tienda_Oficial;

-- CREAR TABLA 11 INVENTARIO 
CREATE TABLE Inventario (
	Inventario_ID INT IDENTITY (1,1) PRIMARY KEY, -- ID UNICO DEL REGISTRO DEL INVENTARIO
	Tienda_ID INT NOT NULL,  -- LLAVE FORANEA HACIA TIENDA OFICIAL
	Variante_ID INT NOT NULL,  -- LLAVE FORANEA HACIA PRODUTO VARIANTE
	Stock_Actual INT NOT NULL DEFAULT 0, -- CANTIDAD DISPONIBLE EN ESA TIENDA
	Ubicacion_Bodega VARCHAR (50), -- PASILLO ESTANTE O UBICACION FISICA
	Fecha_Ultima_Actualizacion DATETIME DEFAULT GETDATE(),-- ULTIMA VES QUE SE ACTUALIZO

	-- REGLA PARA NO DUPLICAR LA MISMA VARIANTE EN LA MISMA TIENDA

	CONSTRAINT UQ_Tienda_Variante UNIQUE(Tienda_ID, Variante_ID),

	-- RELACIONES CON LA OTRAS TABLAS
	CONSTRAINT FK_Inventario_Tienda FOREIGN KEY (Tienda_ID) REFERENCES Tienda_Oficial(Tienda_ID),
	CONSTRAINT FK_Inventario_Variante FOREIGN KEY (Variante_ID) REFERENCES Producto_Variante(Variante_ID)
);


-- INSERTAR DATOS DE PRUEBA EN INVENTARIO
-- (Asumiendo que ya tienes tiendas y variantes creadas previamente)
INSERT INTO Inventario (Tienda_ID, Variante_ID, Stock_Actual, Ubicacion_Bodega) 
VALUES 
(1, 1, 10, 'Pasillo A - Estante 2'), -- Tienda 1, Variante 1, Stock: 10
(1, 2, 5, 'Pasillo A - Estante 3'),  -- Tienda 1, Variante 2, Stock: 5
(2, 1, 8, 'Bodega Principal - Rack 1'); -- Tienda 2, Variante 1, Stock: 8

-- CONSULTAR EL INVENTARIO CON UN JOIN PARA VER LOS NOMBRES
SELECT 
    I.Inventario_ID,
    T.Nombre_Tienda,
    PV.Variante_ID,
    I.Stock_Actual,
    I.Ubicacion_Bodega,
    I.Fecha_Ultima_Actualizacion
FROM Inventario I
INNER JOIN Tienda_Oficial T ON I.Tienda_ID = T.Tienda_ID
INNER JOIN Producto_Variante PV ON I.Variante_ID = PV.Variante_ID;

-- CREAR TABLA 12 COMPRA_TIENDA
CREATE TABLE Compra_Tienda (
	Compra_Tienda_ID INT IDENTITY (1,1) PRIMARY KEY, -- ID UNICO DE LA COMPRA
	Tienda_ID INT NOT NULL, -- TIENDA QUE RECIBE LA COMPRA
	Proveedor_ID INT NOT NULL, -- PROVEEDOR AL QUE SE LE COMPRO
	Fecha_Compra DATETIME DEFAULT GETDATE(), --FECHA Y HORA DE LA COMPRA
	Numero_Factura_Origen VARCHAR (50), -- NUMERO DE FACTURA O DOCUMENTO DEL PROVEEDOR
	Total_Gasto DECIMAL(10,2) DEFAULT 0.00, -- TOTAL DE LA COMPRA

	-- RELACIONES LLAVES FORANEAS
	CONSTRAINT FK_CompraTienda_Tienda FOREIGN KEY (Tienda_ID) REFERENCES Tienda_Oficial(Tienda_ID),
	CONSTRAINT FK_CompraTienda_Proveedor FOREIGN KEY (Proveedor_ID) REFERENCES Proveedor(Proveedor_ID)
);


-- INSERTAR REGISTROS DE PRUEBA EN COMPRA_TIENDA
INSERT INTO Compra_Tienda (Tienda_ID, Proveedor_ID, Numero_Factura_Origen, Total_Gasto)
VALUES 
(1, 1, 'FAC-89012', 1500.00),
(1, 2, 'FAC-10023', 3200.50);

-- CONSULTAR LAS COMPRAS REALIZADAS
SELECT 
    C.Compra_Tienda_ID,
    T.Nombre_Tienda,
    P.Nombre_Empresa AS Proveedor,
    C.Fecha_Compra,
    C.Numero_Factura_Origen,
    C.Total_Gasto
FROM Compra_Tienda C
INNER JOIN Tienda_Oficial T ON C.Tienda_ID = T.Tienda_ID
INNER JOIN Proveedor P ON C.Proveedor_ID = P.Proveedor_ID;


-- CREAR TABLA 13 DETALLE_COMPRA
CREATE TABLE Detalle_Compra (
    Detalle_Compra_ID INT IDENTITY (1,1) PRIMARY KEY, -- ID ÚNICO DEL DETALLE DE COMPRA
    Compra_Tienda_ID INT NOT NULL,                    -- LLAVE FORÁNEA HACIA COMPRA_TIENDA
    Variante_ID INT NOT NULL,                         -- LLAVE FORÁNEA HACIA PRODUCTO_VARIANTE
    Cantidad INT NOT NULL,                            -- CANTIDAD DE PARES COMPRADOS
    Precio_Costo_Unitario DECIMAL(10,2) NOT NULL,     -- PRECIO UNITARIO DE COMPRA

    -- RELACIONES (LLAVES FORÁNEAS)
    CONSTRAINT FK_DetalleCompra_Compra FOREIGN KEY (Compra_Tienda_ID) REFERENCES Compra_Tienda(Compra_Tienda_ID),
    CONSTRAINT FK_DetalleCompra_Variante FOREIGN KEY (Variante_ID) REFERENCES Producto_Variante(Variante_ID)
);

-- INSERTAR DETALLES DE PRUEBA (Asumiendo que ya existen compras y variantes registradas)
INSERT INTO Detalle_Compra (Compra_Tienda_ID, Variante_ID, Cantidad, Precio_Costo_Unitario)
VALUES 
(1, 1, 20, 150.00), -- 20 pares de la variante 1 en la compra 1 a un costo de 150.00
(1, 2, 10, 200.00), -- 10 pares de la variante 2 en la compra 1 a un costo de 200.00
(2, 1, 15, 155.00); -- 15 pares de la variante 1 en la compra 2 a un costo de 155.00

-- CONSULTAR EL DETALLE DE LAS COMPRAS CON SUS NOMBRES
SELECT 
    DC.Detalle_Compra_ID,
    DC.Compra_Tienda_ID,
    DC.Variante_ID,
    DC.Cantidad,
    DC.Precio_Costo_Unitario,
    (DC.Cantidad * DC.Precio_Costo_Unitario) AS Subtotal
FROM Detalle_Compra DC;



-- CREAR TABLA 14 FACTURA (CABECERA DE VENTA)
CREATE TABLE Factura (
    Factura_ID INT IDENTITY (1,1) PRIMARY KEY,   -- ID ÚNICO DE LA FACTURA
    Cliente_ID INT NOT NULL,                     -- CLIENTE QUE REALIZA LA COMPRA
    Empleado_ID INT NOT NULL,                    -- EMPLEADO QUE ATIENDE LA VENTA
    Tienda_ID INT NOT NULL,                      -- TIENDA DONDE SE REALIZA LA VENTA
    Fecha_Venta DATETIME DEFAULT GETDATE(),      -- FECHA Y HORA DE LA VENTA
    Total_Venta DECIMAL(10,2) DEFAULT 0.00,      -- MONTO TOTAL DE LA FACTURA

    -- RELACIONES (LLAVES FORÁNEAS)
    CONSTRAINT FK_Factura_Cliente FOREIGN KEY (Cliente_ID) REFERENCES Cliente(Cliente_ID),
    CONSTRAINT FK_Factura_Empleado FOREIGN KEY (Empleado_ID) REFERENCES Empleado(Empleado_ID),
    CONSTRAINT FK_Factura_Tienda FOREIGN KEY (Tienda_ID) REFERENCES Tienda_Oficial(Tienda_ID)
);

-- INSERTAR FACTURAS DE PRUEBA 
-- (Asegúrate de que existan al menos un Cliente, un Empleado y una Tienda creados previamente)
INSERT INTO Factura (Cliente_ID, Empleado_ID, Tienda_ID, Total_Venta)
VALUES 
(1, 1, 1, 450.00), -- Venta realizada al cliente 1, atendido por empleado 1 en tienda 1
(2, 2, 1, 890.50); -- Venta realizada al cliente 2, atendido por empleado 2 en tienda 1

-- CONSULTAR LAS FACTURAS CON SUS NOMBRES RELACIONADOS
SELECT 
    F.Factura_ID,
    C.Nombre + ' ' + C.Apellido AS Cliente,
    E.Nombre + ' ' + E.Apellido AS Empleado,
    T.Nombre_Tienda,
    F.Fecha_Venta,
    F.Total_Venta
FROM Factura F
INNER JOIN Cliente C ON F.Cliente_ID = C.Cliente_ID
INNER JOIN Empleado E ON F.Empleado_ID = E.Empleado_ID
INNER JOIN Tienda_Oficial T ON F.Tienda_ID = T.Tienda_ID;

-- CREAR TABLA 15 DETALLE_FACTURA
CREATE TABLE Detalle_Factura (
    Detalle_Factura_ID INT IDENTITY (1,1) PRIMARY KEY, -- ID ÚNICO DEL DETALLE DE VENTA
    Factura_ID INT NOT NULL,                          -- LLAVE FORÁNEA HACIA FACTURA
    Variante_ID INT NOT NULL,                         -- LLAVE FORÁNEA HACIA PRODUCTO_VARIANTE
    Cantidad INT NOT NULL,                            -- CANTIDAD DE PARES VENDIDOS
    Precio_Unitario DECIMAL(10,2) NOT NULL,           -- PRECIO DE VENTA UNITARIO

    -- RELACIONES (LLAVES FORÁNEAS)
    CONSTRAINT FK_DetalleFactura_Factura FOREIGN KEY (Factura_ID) REFERENCES Factura(Factura_ID),
    CONSTRAINT FK_DetalleFactura_Variante FOREIGN KEY (Variante_ID) REFERENCES Producto_Variante(Variante_ID)
);

-- INSERTAR DETALLES DE PRUEBA (Asumiendo que ya existen facturas y variantes creadas)
INSERT INTO Detalle_Factura (Factura_ID, Variante_ID, Cantidad, Precio_Unitario)
VALUES 
(1, 1, 1, 450.00), -- 1 par de la variante 1 en la factura 1
(2, 2, 2, 445.25); -- 2 pares de la variante 2 en la factura 2

-- CONSULTAR EL DETALLE DE LAS FACTURAS CON SU SUBTOTAL
SELECT 
    DF.Detalle_Factura_ID,
    DF.Factura_ID,
    DF.Variante_ID,
    DF.Cantidad,
    DF.Precio_Unitario,
    (DF.Cantidad * DF.Precio_Unitario) AS Subtotal
FROM Detalle_Factura DF;

-- CREAR TABLA 16 DEVOLUCION
CREATE TABLE Devolucion (
    Devolucion_ID INT IDENTITY (1,1) PRIMARY KEY, -- ID ÚNICO DE LA DEVOLUCIÓN
    Factura_ID INT NOT NULL,                          -- FACTURA ASOCIADA A LA COMPRA ORIGINAL
    Empleado_ID INT NOT NULL,                         -- EMPLEADO QUE AUTORIZA/ATIENDE LA DEVOLUCIÓN
    Fecha_Devolucion DATETIME DEFAULT GETDATE(),      -- FECHA Y HORA DE LA DEVOLUCIÓN
    Motivo VARCHAR(255) NOT NULL,                     -- MOTIVO (Ej. Cambio de talla, defecto, etc.)
    Monto_Reembolso DECIMAL(10,2) DEFAULT 0.00,       -- MONTO A REEMBOLSAR O ACREDITAR

    -- RELACIONES (LLAVES FORÁNEAS)
    CONSTRAINT FK_Devolucion_Factura FOREIGN KEY (Factura_ID) REFERENCES Factura(Factura_ID),
    CONSTRAINT FK_Devolucion_Empleado FOREIGN KEY (Empleado_ID) REFERENCES Empleado(Empleado_ID)
);

-- INSERTAR UNA DEVOLUCIÓN DE PRUEBA
-- (Asegúrate de que existan facturas y empleados previos)
INSERT INTO Devolucion (Factura_ID, Empleado_ID, Motivo, Monto_Reembolso)
VALUES 
(1, 1, 'Cambio de talla (Era muy pequeño)', 450.00);

-- CONSULTAR LAS DEVOLUCIONES
SELECT 
    D.Devolucion_ID,
    D.Factura_ID,
    E.Nombre + ' ' + E.Apellido AS Empleado_Atendio,
    D.Fecha_Devolucion,
    D.Motivo,
    D.Monto_Reembolso
FROM Devolucion D
INNER JOIN Empleado E ON D.Empleado_ID = E.Empleado_ID;

-- CREAR TABLA 17 DETALLE_DEVOLUCION
CREATE TABLE Detalle_Devolucion (
    Detalle_Devolucion_ID INT IDENTITY (1,1) PRIMARY KEY, -- ID ÚNICO DEL DETALLE DE DEVOLUCIÓN
    Devolucion_ID INT NOT NULL,                           -- LLAVE FORÁNEA HACIA DEVOLUCION
    Variante_ID INT NOT NULL,                             -- LLAVE FORÁNEA HACIA PRODUCTO_VARIANTE
    Cantidad INT NOT NULL,                                -- CANTIDAD DE PARES DEVUELTOS
    Precio_Unitario DECIMAL(10,2) NOT NULL,               -- PRECIO UNITARIO DEL PRODUCTO DEVUELTO

    -- RELACIONES (LLAVES FORÁNEAS)
    CONSTRAINT FK_DetalleDevolucion_Devolucion FOREIGN KEY (Devolucion_ID) REFERENCES Devolucion(Devolucion_ID),
    CONSTRAINT FK_DetalleDevolucion_Variante FOREIGN KEY (Variante_ID) REFERENCES Producto_Variante(Variante_ID)
);


-- INSERTAR UN DETALLE DE DEVOLUCIÓN DE PRUEBA
-- (Asegúrate de que existan devoluciones y variantes previas)
INSERT INTO Detalle_Devolucion (Devolucion_ID, Variante_ID, Cantidad, Precio_Unitario)
VALUES 
(1, 1, 1, 450.00); -- 1 par de la variante 1 devuelto en la devolución 1

-- CONSULTAR LOS DETALLES DE DEVOLUCIÓN CON SU SUBTOTAL
SELECT 
    DD.Detalle_Devolucion_ID,
    DD.Devolucion_ID,
    DD.Variante_ID,
    DD.Cantidad,
    DD.Precio_Unitario,
    (DD.Cantidad * DD.Precio_Unitario) AS Subtotal_Devuelto
FROM Detalle_Devolucion DD;

-- Tabla del Catálogo de Métodos de Pago
CREATE TABLE Metodo_Pago (
    Metodo_Pago_ID INT IDENTITY (1,1) PRIMARY KEY,
    Nombre VARCHAR (50) NOT NULL,
    Descripcion VARCHAR (255),
    Activo BIT DEFAULT 1
);

-- 1. Insertar Métodos de Pago
INSERT INTO Metodo_Pago (Nombre, Descripcion, Activo) VALUES 
('Efectivo', 'Pago en efectivo', 1),
('Tarjeta', 'Tarjeta de crédito o débito', 1);

SELECT * FROM Metodo_Pago;

-- Tabla Principal de Pago
CREATE TABLE Pago (
    Pago_ID INT IDENTITY (1,1) PRIMARY KEY,
    Metodo_Pago_ID INT NOT NULL,                    -- Relación con el catálogo Metodo_Pago
    Monto_Pagado DECIMAL(10,2) NOT NULL,
    Referencia_Pago VARCHAR(100),
    Fecha_Pago DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_Pago_MetodoPago FOREIGN KEY (Metodo_Pago_ID) REFERENCES Metodo_Pago(Metodo_Pago_ID)
);

-- 2. Insertar un Pago (ej: usando el método 1 'Efectivo', pagando 450.00)
INSERT INTO Pago (Metodo_Pago_ID, Monto_Pagado, Referencia_Pago) VALUES 
(1, 450.00, 'EFECTIVO-001');

CREATE TABLE Pago_Factura (
    Pago_Factura_ID INT IDENTITY (1,1) PRIMARY KEY,
    Pago_ID INT NOT NULL,
    Factura_ID INT NOT NULL,
    Monto_Aplicado DECIMAL(10,2) NOT NULL,

    CONSTRAINT FK_PagoFactura_Pago FOREIGN KEY (Pago_ID) REFERENCES Pago(Pago_ID),
    CONSTRAINT FK_PagoFactura_Factura FOREIGN KEY (Factura_ID) REFERENCES Factura(Factura_ID)
);

-- 3. Asociar el Pago a la Factura (ej: Pago ID 1 asociado a la Factura ID 1)
INSERT INTO Pago_Factura (Pago_ID, Factura_ID, Monto_Aplicado) VALUES 
(1, 1, 450.00);

SELECT 
    C.Cliente_ID,
    C.Nombre + ' ' + C.Apellido AS Nombre_Cliente,
    F.Factura_ID,
    F.Fecha_Venta,
    F.Total_Venta AS Total_Facturado,
    P.Pago_ID,
    MP.Nombre AS Metodo_Pago_Utilizado,
    PF.Monto_Aplicado AS Monto_Pagado,
    P.Referencia_Pago,
    P.Fecha_Pago
FROM Cliente C
INNER JOIN Factura F ON C.Cliente_ID = F.Cliente_ID
INNER JOIN Pago_Factura PF ON F.Factura_ID = PF.Factura_ID
INNER JOIN Pago P ON PF.Pago_ID = P.Pago_ID
INNER JOIN Metodo_Pago MP ON P.Metodo_Pago_ID = MP.Metodo_Pago_ID;


SELECT * FROM Cliente;