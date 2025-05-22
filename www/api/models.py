
from pydantic import BaseModel, Field

class SeasonOverallTeamStrength(BaseModel):
    """
    Model for the overall team strength of a season.
    """
    parameter_type: str = Field(..., description="The type of parameter used for the model.")
    season: str = Field(..., description="The season in which the team strength is calculated.")
    team_nm: str = Field(..., description="The name of the team.")
    team_logo: str = Field(..., description="The URL of the team's logo.")
    division_nm: str = Field(..., description="The name of the division.")
    conference_nm: str = Field(..., description="The name of the conference.")
    median: float = Field(..., description="Median overall strength of the team.")
    q5: float = Field(..., description="5th percentile of the overall strength.")
    q95: float = Field(..., description="95th percentile of the overall strength.")





