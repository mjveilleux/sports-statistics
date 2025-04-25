
import cmdstanpy
import duckdb
import os
import pathlib
 
# this module contains the functions needed to:
        # 1. connect and return table from duckdb 
        # 2. format the stan data for the stan model
        # 3. run the stan model (with an arg for which model to run)
        # 4. summarise the stan model results
        # 5. export the data to duckdb 


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


def execute_query(conn, query: str):
    """
    Execute a SQL query on the DuckDB database.

    Args:
        conn (duckdb.DuckDBPyConnection): Connection object to the DuckDB database.
        query (str): SQL query to execute
    """
    try:
        conn.execute(query)
    except Exception as e:
        print(f"Error executing query: {e}")
    finally:
        conn.close()

def get_parquet_file_from_data_folder(filepath: str):

    """
    Get the path to a parquet file in the data folder.
    Args:
        filename (str): Name of the parquet file.
    Returns:
        str: Path to the parquet file.
    """
    return os.path.sep(filepath)
    return conn.fetchdf()



def format_stan_data(df, stan_model):
    """
    Format the data for the Stan model.

    Args:
        df (pd.DataFrame): DataFrame containing the data to be formatted.
        stan_model (str): Name of the Stan model to be used.

    Returns:
        dict: Formatted data for the Stan model.
    """
    # Example formatting, adjust according to your model
    stan_data = {
        'N': len(df),
        'x': df['x'].values,
        'y': df['y'].values
    }
    return stan_data


def run_stan_model(stan_data, stan_model):
    """
    Run the Stan model.

    Args:
        stan_data (dict): Formatted data for the Stan model.
        stan_model (str): Name of the Stan model to be used.

    Returns:
        dict: Results from the Stan model.
    """
    import pystan

    # Compile and fit the model
    sm = cmdstanpy.StanModel(file=stan_model)
    fit = sm.sampling(data=stan_data, iter=1000, chains=4)
    
    return fit





__name__ == "__main__":

    db_path = 'path/to/your/database.duckdb'
    conn = get_duckdb_connection(db_path)
    
    query = "SELECT * FROM nfl.historical_games_points"
    df = execute_query(conn, query)
    
    stan_model = 'stan/v1.stan'
    stan_data = format_stan_data(df, stan_model)
    
    results = run_stan_model(stan_data, stan_model)
    
    print(results)
