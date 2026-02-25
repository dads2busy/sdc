# Census 2010 to 2020 Geographies

This code is used to prepare and visualize material deprivation data for Virginia at the census tract level, with a focus on making data from different years directly comparable. Census tract boundaries often change between decades, so data from earlier years (like 2010) may not align with newer boundaries (like those from 2020). This code standardizes older data to the 2020 boundaries, allowing for a more accurate analysis over time. 

We do this because comparing data across years without accounting for boundary changes can lead to misleading conclusions. Standardizing ensures that trends in deprivation or inequality reflect actual changes in communities, not just shifts in how geographic areas are defined. By mapping both the original and standardized data, this process also helps researchers and policymakers understand the impact of boundary changes and make more informed decisions based on consistent geographic units.

It takes in a finalized tract dataset and standardizes the values to fit 2020 tract boundaries. It assumes that the dataset fits the data commons conventions for finalized data (columns: geoid, year, measure, value, moe, region_type || measure names: snake case - underscore delimeter) param: data(dataframe) -> tract data fitting data commons conventions (outlined above) param: filter_geo(character - default="state") -> geographic level to keep consistent with original data. (for example, if your original data only contains specific states like Virginia, use "state". if your original data only contains specific counties like Fairfax and Arlington, use "county") return: same dataframe with values standardized to 2020 boundaries.

## Installation
remotes::install_github("https://github.com/uva-bi-sdad/sdc.census10to20")
