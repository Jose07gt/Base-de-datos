from pydantic import BaseModel
from typing import Optional

# Modelo para registrar una Venta a través del Stored Procedure
class VentaCreate(BaseModel):
    cliente_id: int
    empleado_id: int
    tienda_id: int
    variante_id: int
    cantidad: int
    precio_unitario: float
    metodo_pago_id: int
    referencia_pago: str