
import duckdb


def get_duckdb_connection(db_path: str):
    """
    Create a connection to a DuckDB database.

    Args:
        db_path (str): Path to the DuckDB database file.

    Returns:
        duckdb.DuckDBPyConnection: Connection object to the DuckDB database.
    """
    conn = duckdb.connect(db_path)
    return conn


