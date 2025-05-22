

# LLM Context for website


This is a file that will contain the context an LLM needs to initialize the website for my project.


# Vision of the website


we are going to do a NextJS app with FASTAPI.


The APIs are already created with my FastAPI thing in the api/ folder.

The website will look similar to 538's and ESPN's in the sense of organization of graphs and data.


There is a lot of power in the visualizeations of these models so we will be relying on typescript charting features.



There will first be a main loading page that explains what this website is for. 
## layout


### HOME PAGE 
on the nav bar will be:

Far left: Home page click on logo (very common)

Right side:

    - About 
    - Strengths by Season (drop down of seasons)
        - overall
        - offense
        - defense
    - Teams
        - [divisions and stuff]

    - Analysis and Breakdowns
        - How we estimate team strengths.
        - Top defenses
        - Top Offenses
        - Top Overall Teams

    - Road to the Super Bowl [Blog post series]
        - Following [team] to Super Bowl [number]
     

home page will have an interactive plot or table that showcases overall team strengths over time


## ABOUT


#### What is this thing?
"XX company name XX" provides team strength estimates for American Football teams.
company uses bayesian inference to model team strength estimates over seasons and weeks
The approach allows us to estimate the uncertainty around team strength estimates giving us better insight in the probability of match outcomes for both teams, offense and defense.
This is in contrast to deterministic measures of team strength seen in ESPN analyses and ELO rankings.

#### Some notable references
The model stands on top of a mountain of research and academic literature. Below is a link to the main sources used and those that gave inspiration:
1. Michael Lopez work
2. Glickman and Stern
3. Comprehensive American Football model repo
4. Mark Rieke's Um Factually and MADHATTER



home page will have the above descriptions

clicking on Strengths by Season


( we should try and find the old 538 website -- that shit was fire)


