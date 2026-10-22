from fastapi import FastAPI, HTTPException, status
from pydantic import BaseModel
from typing import Optional
import pyodbc
from database import get_db_connection

from fastapi import FastAPI
from fastapi.responses import HTMLResponse

app = FastAPI(
    title="👟 NovaTech - Sistema de Gestión de Zapatería API",
    version="1.0.0",
    description="""
    ## 🚀 Proyecto Final - Bases de Datos I
    API REST de alto rendimiento desarrollada con **FastAPI** y **SQL Server**.
    """,
    docs_url="/docs",  # URL para Swagger UI
    redoc_url="/redoc" # URL para ReDoc
)

# ==========================================
# 1. MODELOS PYDANTIC (Validación de Datos)
# ==========================================

class MarcaCreate(BaseModel):
    Nombre_Marca: str

class CategoriaCreate(BaseModel):
    Estilo_Zapato: str

class ColorCreate(BaseModel):
    Color: str

class TallaCreate(BaseModel):
    Numero_Talla: str
    Escala: str

class ClienteCreate(BaseModel):
    Nombre: str
    Apellido: str
    Telefono: Optional[str] = None
    Correo: Optional[str] = None
    NIT: Optional[str] = None

class VentaCreate(BaseModel):
    Cliente_ID: int
    Empleado_ID: int
    Tienda_ID: int
    Variante_ID: int
    Cantidad: int
    Precio_Unitario: float
    Metodo_Pago_ID: int
    Referencia_Pago: str

class DevolucionCreate(BaseModel):
    Factura_ID: int
    Empleado_ID: int
    Variante_ID: int
    Cantidad: int
    Precio_Unitario: float
    Motivo: str


# ==========================================
# 2. CRUD PARA LAS 5 TABLAS REQUERIDAS
# ==========================================

# --- TABLA 1: MARCA ---
@app.get("/marcas/", tags=["1. CRUDs (5 Tablas) - Marcas"])
def obtener_marcas():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT Marca_ID, Nombre_Marca FROM Marca")
    rows = cursor.fetchall()
    conn.close()
    return [{"Marca_ID": r.Marca_ID, "Nombre_Marca": r.Nombre_Marca} for r in rows]

@app.post("/marcas/", status_code=status.HTTP_201_CREATED, tags=["1. CRUDs (5 Tablas) - Marcas"])
def crear_marca(marca: MarcaCreate):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("INSERT INTO Marca (Nombre_Marca) VALUES (?)", marca.Nombre_Marca)
        conn.commit()
        cursor.execute("SELECT @@IDENTITY")
        new_id = cursor.fetchone()[0]
    except pyodbc.IntegrityError:
        conn.rollback()
        raise HTTPException(status_code=400, detail="La marca ya existe o viola una regla de unicidad.")
    finally:
        conn.close()
    return {"mensaje": "Marca creada exitosamente", "Marca_ID": new_id, **marca.dict()}

@app.put("/marcas/{marca_id}", tags=["1. CRUDs (5 Tablas) - Marcas"])
def actualizar_marca(marca_id: int, marca: MarcaCreate):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT Marca_ID FROM Marca WHERE Marca_ID = ?", marca_id)
    if not cursor.fetchone():
        conn.close()
        raise HTTPException(status_code=404, detail="Marca no encontrada")
    cursor.execute("UPDATE Marca SET Nombre_Marca = ? WHERE Marca_ID = ?", marca.Nombre_Marca, marca_id)
    conn.commit()
    conn.close()
    return {"mensaje": "Marca actualizada correctamente"}

@app.delete("/marcas/{marca_id}", tags=["1. CRUDs (5 Tablas) - Marcas"])
def eliminar_marca(marca_id: int):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("DELETE FROM Marca WHERE Marca_ID = ?", marca_id)
        conn.commit()
    except pyodbc.IntegrityError:
        conn.rollback()
        raise HTTPException(status_code=400, detail="No se puede eliminar la marca porque está asociada a modelos de calzado.")
    finally:
        conn.close()
    return {"mensaje": "Marca eliminada correctamente"}


# --- TABLA 2: CATEGORIA ---
@app.get("/categorias/", tags=["1. CRUDs (5 Tablas) - Categorias"])
def obtener_categorias():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT Categoria_ID, Estilo_Zapato FROM Categoria")
    rows = cursor.fetchall()
    conn.close()
    return [{"Categoria_ID": r.Categoria_ID, "Estilo_Zapato": r.Estilo_Zapato} for r in rows]

@app.post("/categorias/", status_code=status.HTTP_201_CREATED, tags=["1. CRUDs (5 Tablas) - Categorias"])
def crear_categoria(cat: CategoriaCreate):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("INSERT INTO Categoria (Estilo_Zapato) VALUES (?)", cat.Estilo_Zapato)
        conn.commit()
        cursor.execute("SELECT @@IDENTITY")
        new_id = cursor.fetchone()[0]
    except pyodbc.IntegrityError:
        conn.rollback()
        raise HTTPException(status_code=400, detail="La categoría ya existe.")
    finally:
        conn.close()
    return {"mensaje": "Categoría creada", "Categoria_ID": new_id, **cat.dict()}

@app.put("/categorias/{cat_id}", tags=["1. CRUDs (5 Tablas) - Categorias"])
def actualizar_categoria(cat_id: int, cat: CategoriaCreate):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("UPDATE Categoria SET Estilo_Zapato = ? WHERE Categoria_ID = ?", cat.Estilo_Zapato, cat_id)
    conn.commit()
    conn.close()
    return {"mensaje": "Categoría actualizada"}

@app.delete("/categorias/{cat_id}", tags=["1. CRUDs (5 Tablas) - Categorias"])
def eliminar_categoria(cat_id: int):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("DELETE FROM Categoria WHERE Categoria_ID = ?", cat_id)
        conn.commit()
    except pyodbc.IntegrityError:
        conn.rollback()
        raise HTTPException(status_code=400, detail="No se puede eliminar la categoría porque está en uso.")
    finally:
        conn.close()
    return {"mensaje": "Categoría eliminada"}


# --- TABLA 3: COLOR ---
@app.get("/colores/", tags=["1. CRUDs (5 Tablas) - Colores"])
def obtener_colores():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT Color_ID, Color FROM Color")
    rows = cursor.fetchall()
    conn.close()
    return [{"Color_ID": r.Color_ID, "Color": r.Color} for r in rows]

@app.post("/colores/", status_code=status.HTTP_201_CREATED, tags=["1. CRUDs (5 Tablas) - Colores"])
def crear_color(color: ColorCreate):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("INSERT INTO Color (Color) VALUES (?)", color.Color)
        conn.commit()
        cursor.execute("SELECT @@IDENTITY")
        new_id = cursor.fetchone()[0]
    except pyodbc.IntegrityError:
        conn.rollback()
        raise HTTPException(status_code=400, detail="El color ya existe.")
    finally:
        conn.close()
    return {"mensaje": "Color creado", "Color_ID": new_id, **color.dict()}

@app.put("/colores/{color_id}", tags=["1. CRUDs (5 Tablas) - Colores"])
def actualizar_color(color_id: int, color: ColorCreate):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("UPDATE Color SET Color = ? WHERE Color_ID = ?", color.Color, color_id)
    conn.commit()
    conn.close()
    return {"mensaje": "Color actualizado"}

@app.delete("/colores/{color_id}", tags=["1. CRUDs (5 Tablas) - Colores"])
def eliminar_color(color_id: int):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("DELETE FROM Color WHERE Color_ID = ?", color_id)
        conn.commit()
    except pyodbc.IntegrityError:
        conn.rollback()
        raise HTTPException(status_code=400, detail="No se puede eliminar el color porque está en uso.")
    finally:
        conn.close()
    return {"mensaje": "Color eliminado"}


# --- TABLA 4: TALLA ---
@app.get("/tallas/", tags=["1. CRUDs (5 Tablas) - Tallas"])
def obtener_tallas():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT Talla_ID, Numero_Talla, Escala FROM Talla")
    rows = cursor.fetchall()
    conn.close()
    return [{"Talla_ID": r.Talla_ID, "Numero_Talla": r.Numero_Talla, "Escala": r.Escala} for r in rows]

@app.post("/tallas/", status_code=status.HTTP_201_CREATED, tags=["1. CRUDs (5 Tablas) - Tallas"])
def crear_talla(talla: TallaCreate):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("INSERT INTO Talla (Numero_Talla, Escala) VALUES (?, ?)", talla.Numero_Talla, talla.Escala)
    conn.commit()
    cursor.execute("SELECT @@IDENTITY")
    new_id = cursor.fetchone()[0]
    conn.close()
    return {"mensaje": "Talla creada", "Talla_ID": new_id, **talla.dict()}

@app.put("/tallas/{talla_id}", tags=["1. CRUDs (5 Tablas) - Tallas"])
def actualizar_talla(talla_id: int, talla: TallaCreate):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("UPDATE Talla SET Numero_Talla = ?, Escala = ? WHERE Talla_ID = ?", talla.Numero_Talla, talla.Escala, talla_id)
    conn.commit()
    conn.close()
    return {"mensaje": "Talla actualizada"}

@app.delete("/tallas/{talla_id}", tags=["1. CRUDs (5 Tablas) - Tallas"])
def eliminar_talla(talla_id: int):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("DELETE FROM Talla WHERE Talla_ID = ?", talla_id)
        conn.commit()
    except pyodbc.IntegrityError:
        conn.rollback()
        raise HTTPException(status_code=400, detail="No se puede eliminar la talla porque está en uso.")
    finally:
        conn.close()
    return {"mensaje": "Talla eliminada"}


# --- TABLA 5: CLIENTE ---
@app.get("/clientes/", tags=["1. CRUDs (5 Tablas) - Clientes"])
def obtener_clientes():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT Cliente_ID, Nombre, Apellido, Telefono, Correo, NIT, Fecha_Registro FROM Cliente")
    rows = cursor.fetchall()
    conn.close()
    return [{"Cliente_ID": r.Cliente_ID, "Nombre": r.Nombre, "Apellido": r.Apellido, "Telefono": r.Telefono, "Correo": r.Correo, "NIT": r.NIT, "Fecha_Registro": str(r.Fecha_Registro)} for r in rows]

@app.post("/clientes/", status_code=status.HTTP_201_CREATED, tags=["1. CRUDs (5 Tablas) - Clientes"])
def crear_cliente(cliente: ClienteCreate):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("INSERT INTO Cliente (Nombre, Apellido, Telefono, Correo, NIT) VALUES (?, ?, ?, ?, ?)",
                   cliente.Nombre, cliente.Apellido, cliente.Telefono, cliente.Correo, cliente.NIT)
    conn.commit()
    cursor.execute("SELECT @@IDENTITY")
    new_id = cursor.fetchone()[0]
    conn.close()
    return {"mensaje": "Cliente registrado", "Cliente_ID": new_id, **cliente.dict()}

@app.put("/clientes/{cliente_id}", tags=["1. CRUDs (5 Tablas) - Clientes"])
def actualizar_cliente(cliente_id: int, cliente: ClienteCreate):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("UPDATE Cliente SET Nombre = ?, Apellido = ?, Telefono = ?, Correo = ?, NIT = ? WHERE Cliente_ID = ?",
                   cliente.Nombre, cliente.Apellido, cliente.Telefono, cliente.Correo, cliente.NIT, cliente_id)
    conn.commit()
    conn.close()
    return {"mensaje": "Cliente actualizado"}

@app.delete("/clientes/{cliente_id}", tags=["1. CRUDs (5 Tablas) - Clientes"])
def eliminar_cliente(cliente_id: int):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("DELETE FROM Cliente WHERE Cliente_ID = ?", cliente_id)
        conn.commit()
    except pyodbc.IntegrityError:
        conn.rollback()
        raise HTTPException(status_code=400, detail="No se puede eliminar el cliente porque tiene facturas registradas.")
    finally:
        conn.close()
    return {"mensaje": "Cliente eliminado"}


# ==========================================
# 3. PROCEDIMIENTOS ALMACENADOS Y TRANSACCIONES
# ==========================================

@app.post("/ventas/registrar", tags=["2. Procedimientos Almacenados"])
def registrar_venta_api(venta: VentaCreate):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        # Llamada al Stored Procedure sp_RegistrarVenta
        sql = "{CALL sp_RegistrarVenta (?, ?, ?, ?, ?, ?, ?, ?)}"
        params = (
            venta.Cliente_ID, venta.Empleado_ID, venta.Tienda_ID,
            venta.Variante_ID, venta.Cantidad, venta.Precio_Unitario,
            venta.Metodo_Pago_ID, venta.Referencia_Pago
        )
        cursor.execute(sql, params)
        conn.commit()
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=400, detail=f"Error al registrar la venta (Posible stock insuficiente): {str(e)}")
    finally:
        conn.close()
    return {"mensaje": "Venta registrada exitosamente mediante procedimiento almacenado y transacción."}

@app.post("/devoluciones/registrar", tags=["2. Procedimientos Almacenados"])
def registrar_devolucion_api(dev: DevolucionCreate):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        # Llamada al Stored Procedure sp_RegistrarDevolucion
        sql = "{CALL sp_RegistrarDevolucion (?, ?, ?, ?, ?, ?)}"
        params = (
            dev.Factura_ID, dev.Empleado_ID, dev.Variante_ID,
            dev.Cantidad, dev.Precio_Unitario, dev.Motivo
        )
        cursor.execute(sql, params)
        conn.commit()
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=400, detail=f"Error al registrar la devolución: {str(e)}")
    finally:
        conn.close()
    return {"mensaje": "Devolución procesada exitosamente mediante procedimiento almacenado y transacción."}


# ==========================================
# 4. REPORTES CON FUNCIONES DE AGRUPACIÓN
# ==========================================

@app.get("/reportes/ventas-totales", tags=["3. Reportes (GROUP BY, SUM, COUNT)"])
def reporte_ventas_por_tienda():
    """Reporte 1: Total de ventas, cantidad de facturas y monto recaudado por cada tienda."""
    conn = get_db_connection()
    cursor = conn.cursor()
    query = """
        SELECT 
            T.Nombre_Tienda,
            COUNT(F.Factura_ID) AS Total_Facturas,
            SUM(F.Total_Venta) AS Monto_Total_Ventas,
            AVG(F.Total_Venta) AS Promedio_Venta
        FROM Factura F
        INNER JOIN Tienda_Oficial T ON F.Tienda_ID = T.Tienda_ID
        GROUP BY T.Nombre_Tienda;
    """
    cursor.execute(query)
    rows = cursor.fetchall()
    conn.close()
    return [
        {
            "Tienda": r.Nombre_Tienda,
            "Total_Facturas": r.Total_Facturas,
            "Monto_Total_Ventas": float(r.Monto_Total_Ventas),
            "Promedio_Venta": float(r.Promedio_Venta)
        } for r in rows
    ]

@app.get("/reportes/stock-categorias", tags=["3. Reportes (GROUP BY, SUM, COUNT)"])
def reporte_stock_por_categoria():
    """Reporte 2: Cantidad total de inventario y existencias agrupadas por estilo de zapato (Categoría)."""
    conn = get_db_connection()
    cursor = conn.cursor()
    query = """
        SELECT 
            C.Estilo_Zapato,
            COUNT(DISTINCT MC.Modelo_ID) AS Cantidad_Modelos,
            SUM(I.Stock_Actual) AS Stock_Total_Inventario
        FROM Inventario I
        INNER JOIN Producto_Variante PV ON I.Variante_ID = PV.Variante_ID
        INNER JOIN Modelo_Calzado MC ON PV.Modelo_ID = MC.Modelo_ID
        INNER JOIN Categoria C ON MC.Categoria_ID = C.Categoria_ID
        GROUP BY C.Estilo_Zapato
        HAVING SUM(I.Stock_Actual) >= 0;
    """
    cursor.execute(query)
    rows = cursor.fetchall()
    conn.close()
    return [
        {
            "Estilo_Categoria": r.Estilo_Zapato,
            "Cantidad_Modelos": r.Cantidad_Modelos,
            "Stock_Total_Inventario": r.Stock_Total_Inventario
        } for r in rows
    ] 


    from fastapi.openapi.docs import get_swagger_ui_html

@app.get("/docs", include_in_schema=False)
def custom_swagger_ui_html():
    return get_swagger_ui_html(
        openapi_url=app.openapi_url,
        title=app.title + " - Documentación",
        # Aquí puedes inyectar un tema CSS moderno (por ejemplo, un tema oscuro para Swagger)
        swagger_js_url="https://cdn.jsdelivr.net/npm/swagger-ui-dist@5/swagger-ui-bundle.js",
        swagger_css_url="https://cdn.jsdelivr.net/npm/swagger-ui-dist@5/swagger-ui.css",
    )