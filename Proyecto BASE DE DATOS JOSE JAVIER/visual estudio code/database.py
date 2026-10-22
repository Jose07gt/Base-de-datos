import pyodbc

# Cadena de conexión a tu SQL Server local
CONN_STR = (
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=localhost;"
    "DATABASE=ZAPATERIA;"
    "Trusted_Connection=yes;"
)

def get_db_connection():
    """Abre y regresa una conexión a SQL Server."""
    return pyodbc.connect(CONN_STR)