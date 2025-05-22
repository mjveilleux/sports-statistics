import polars as pl
import multiprocessing
import cmdstanpy
import duckdb
import os
import pathlib

# cmdstanpy.install_cmdstan()

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


def prepare_stan_data_season_overall_strength(historical_games, team_alltime):
    
    
  # Get scalar values directly
    teams_count = teams_dim.select("team_id").unique().count().item()
    games_count = historical_games.select(pl.len()).item()
    seasons_count = historical_games.select("season").unique().count().item()
    
    # Create the stan_data dictionary with proper formats
    stan_data = {
        'teams': teams_count,
        'games': games_count,
        'seasons': seasons_count,
        'H': historical_games.select(pl.col("team_id_home").cast(pl.Int64)).to_series().to_list(),
        'A': historical_games.select(pl.col("team_id_away").cast(pl.Int64)).to_series().to_list(),
        'S': historical_games.select(pl.col("season_index").cast(pl.Int64)).to_series().to_list(), 
        'h_point_diff': historical_games.select(pl.col("home_point_diff").cast(pl.Int64)).to_series().to_list(),
        'h_adv': historical_games.select(pl.col("h_adv").cast(pl.Int64)).to_series().to_list()
    }   

    return stan_data

def run_stan_model(stan_data, model_file, output_dir,
                   chains=4, iter_warmup=1000, iter_sampling=1000, 
                   seed=123456):
    """
    Run a Stan model using cmdstanpy with the provided data.
    
    Parameters:
    -----------
    stan_data : dict
        Dictionary containing the data for the Stan model.
    model_file : str, optional
        Path to the Stan model file, default is "model.stan".
    output_dir : str, optional
        Directory to save the output files, default is "./output".
    chains : int, optional
        Number of Markov chains, default is 4.
    parallel_chains : int, optional
        Number of chains to run in parallel, default is None (use all available cores).
    iter_warmup : int, optional
        Number of warmup iterations, default is 1000.
    iter_sampling : int, optional
        Number of sampling iterations, default is 1000.
    save_warmup : bool, optional
        Whether to save warmup iterations, default is False.
    adapt_delta : float, optional
        Target average acceptance probability for adaptation, default is 0.8.
    max_treedepth : int, optional
        Maximum treedepth for the NUTS sampler, default is 10.
    seed : int, optional
        Random seed, default is 123456.
        
    Returns:
    --------
    CmdStanMCMC
        The fitted Stan model object with samples.
    """
    # Create output directory if it doesn't exist

    # Compile the Stan model
    model = cmdstanpy.CmdStanModel(stan_file=model_file)
    
    # Run the model
    fit = model.sample(
        data=stan_data,
        chains=chains,
        iter_warmup=iter_warmup,
        iter_sampling=iter_sampling,
        show_console=True,
        seed=seed,
        show_progress=True
    )
    
    # Print summary of the results
    fit_summary = fit.summary()
    print(fit_summary)
    
    # Create output directory if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)
    
    # Save the summary to CSV
    csv_path = os.path.join(output_dir, "fit_summary.csv")
    fit_summary.to_csv(csv_path)
    
    return print("Model saved to", output_dir)

if __name__ == "__main__":
    # print("this works")
    db_path = '/Users/masonveilleux/.duckdb/cli/1.2.1/mydatabase.duckdb'
    conn = get_duckdb_connection(db_path)

    games_query = "SELECT * FROM nfl.historical_games_points"
    historical_games = conn.sql(games_query)
    historical_games = pl.DataFrame(historical_games)

    teams_query = "SELECT * FROM nfl.team_alltime"
    teams_dim = conn.sql(teams_query)
    teams_dim = pl.DataFrame(teams_dim)

    stan_data = prepare_stan_data(historical_games,teams_dim)
    # print(stan_data)
    results = run_stan_model(stan_data = stan_data, model_file = 'model/stan/v2.stan', output_dir = "./model/out")




