



# this file contains functions to simulate games for each model 

# model: season/v2.stan 


import polars as pl
import multiprocessing
import cmdstanpy
import duckdb
import os
import pathlib


# get thetas from database 
def get_thetas_from_db(conn, model_name: str):
    """
    Get thetas from the database for a given model.
    
    Args:
        conn (duckdb.DuckDBPyConnection): Connection object to the DuckDB database.
        model_name (str): Name of the model to get thetas for.
        
    Returns:
        list: List of thetas for the given model.
    """
    query = f"SELECT * FROM {model_name}_thetas"
    return conn.execute(query).fetchdf()


# calculate means and standard deviations of _thetas for each team
def calculate_team_stats(thetas_df: pl.DataFrame):
    """
    Calculate means and standard deviations of thetas for each team.
    
    Args:
        thetas_df (pl.DataFrame): DataFrame containing thetas for each team.
        
    Returns:
        pl.DataFrame: DataFrame with means and standard deviations of thetas for each team.
    """
    return thetas_df.groupby("team").agg([
        pl.mean("theta").alias("mean_theta"),
        pl.std("theta").alias("std_theta")
    ])


# simulate next seasons games from nfl schedule
    # inputs: season_to_sim, team_stats, conn 

# the function: 
    # will take team matchups in the schedule_df
    # map the theta mean and sd to each team 
    # simulate 1000 seasons of each matchup using the mean and sd for each theta 
    # calculate the win probability for each team (share of wins at each weeks matchup)
    # summarise results of simulation by returning each teams end of year wins per
    
    # return :
        # a dataframe with the following columns:
        # team, wins, losses, ties, win_percentage, games_played


def simulate_games(team_stats: pl.DataFrame, schedule_df: pl.DataFrame):
    """
    Simulate games using the team stats and the NFL schedule.
    
    Args:
        team_stats (pl.DataFrame): DataFrame containing team stats.
        schedule_df (pl.DataFrame): DataFrame containing the NFL schedule.
        
    Returns:
        pl.DataFrame: DataFrame containing the simulated games.
    """
    # merge the team stats with the schedule
    merged_df = schedule_df.join(team_stats, left_on="home_team", right_on="team", how="left")
    merged_df = merged_df.join(team_stats, left_on="away_team", right_on="team", how="left", suffix="_away")

    # simulate the games using the team stats
    merged_df = merged_df.with_columns(
        (pl.col("mean_theta") - pl.col("mean_theta_away")).alias("home_advantage"),
        (pl.col("std_theta") + pl.col("std_theta_away")).alias("std_dev")
    )

    return merged_df


# run the program 


if __name__ == "__main__":
    # Connect to the database
    conn = duckdb.connect("/Users/masonveilleux/.duckdb/cli/1.2.1/mydatabase.duckdb")
    
    # Get thetas from the database
    thetas_df = get_thetas_from_db(conn, "season/v2")
    print(thetas_df)
    # Calculate team stats
    team_stats = calculate_team_stats(thetas_df)
    print(team_stats)
    # Load the NFL schedule
    schedule_df = conn.sql("""
                SELECT 
                s.season,
                s.week,
                s.home_team, 
                s.away_team,
                s.location,
                th.team_id as home_team_id,
                ta.team_id as away_team_id
                from nfl.schedules as s 
                inner join nfl.team_alltime as th on th.team_location_abbreviation = s.home_team
                inner join nfl.team_alltime as ta on ta.team_location_abbreviation = s.away_team
                where s.season = 2025
                order by week asc
                """)
    print(schedule_df)
    # Simulate games
    simulated_games = simulate_games(team_stats, schedule_df)
    print(simulated_games)
    # Close the database connection
    conn.close()
