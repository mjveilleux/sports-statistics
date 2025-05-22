from pathlib import Path

import duckdb
from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates

from . import funcs
from . import models

# Database path
db_path = "/Users/masonveilleux/.duckdb/cli/1.2.1/mydatabase.duckdb"

# Initialize FastAPI app
app = FastAPI(title="NFL Statistics")

# Mount static directory
app.mount("/static", StaticFiles(directory="./static"), name="static")

# Set up templates
templates = Jinja2Templates(directory="templates")

# Initialize database on startup
@app.on_event("startup")
def startup_db_client():
    funcs.get_duckdb_connection(db_path)

# Root endpoint
@app.get("/", response_class=HTMLResponse)
async def index(request: Request):
    """Serve the index page"""
    return templates.TemplateResponse("home.html", {"request": request})

# API endpoint to return the table
@app.get("/api/season-overall-strengths", response_class=HTMLResponse)
async def get_season_overall_strengths(request: Request):
    """Return overall team strengths over seasons HTML for HTMX to swap in"""
    # Get database connection
    conn = funcs.get_duckdb_connection(db_path)

    # Fetch data from DuckDB as a list of dictionaries
    data = conn.sql(
        "SELECT parameter_type, season, team_nm, division_nm, conference_nm, median FROM nfl.model_summary_team_strength_model_v2"
    ).df().to_dict(orient="records")

    # Format data using the Pydantic model
    strengths = [models.SeasonOverallTeamStrength(**row) for row in data]

    # Return the HTML response using the template
    return templates.TemplateResponse(
        "partials/season-overall-strengths-table.html",
        {
            "request": request,
            "strengths": strengths
        }
    )

