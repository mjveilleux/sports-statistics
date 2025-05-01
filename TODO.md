



# what we've done so far

1. got the data cleaned up (mostly)
2. defined the tables and loaded the data in a local duckdb database
3. created and ran a season by season team strength
4. have a final table of season-by-season team strengths with data to send to API



# What to do next

1. refine the final table so that it takes the latest name for each team (this is because Washington is weird)
2. create an API for our HTMX + FastAPI web app (we gonna b 2 fast 4 u)
3. add some generated quantities in the model
    - best in XYZ
    - put raw thetas in a simplex then posterior.
    - simluate matches for each season with previousd end of season estimates
    - predicted next year's end of season strength based on t-1
4. Start HTMX website
5. scope out how to deploy this

# Longer term

1. new model: week-by-week thetas across seasons (with HFA and bye week variables intercepts)
2. new feature: defense and offense strength 
3. new model: do expected points version of the model
4. new model: simulate actual game outcomes (points scored and points allowed)
    - will compare actual vs distribution of simulated scores by drive
    - maybe we do this on a drive by drive basis? with drives as poisson distributed and drive time as a something idk this could get messy super quick



