# Social Atlas of Athens

### Overview

This repository contains all code and data for the Athens Wellbeing Project's 
Social Atlas of Athens. The dashboard is built using the Shiny package in R and 
visualizes the data described below in the following two ways. The data both 
aggregated by census tract and Elementary School Districts for display on an 
interactive map of Athens-Clarke County.

### Code and Data Structure

**`awp_socialatlas_2022.rmd`** - This file contains the code for the Shiny 
application. In order to function this dashboard requires input of two matrices: 
  
1. The variable **estimates** to be visualized on the dashboard. This matrix must have the following columns:

    * **GEOID or School** - At the tract scale, the **GEOID** column is used identify the census tract associated with the row data. At the school districts scale, **School column** is used properly identify the Elementary School District associated with the row data.

    * **est** - This is a numeric column containing the estimated value for the variable given in the var column

    * **var** - This column contains the short name of the variable the row estimate is referring to. This column is primarily used to join the estimates table to the metadata.
    
    * **description** - This column contains the long form description of the variable that will be displayed within the dashboard.
    
    * **type** - This is a character based binary column used categorize the data using **count** for count data and **pct** for percent calculations. All rows must have either count or pct as the value in this column to be recognized by the dashboard.

2. The variable **metadata** file. This matrix must have the following columns:

    * **variable** - Corresponding column to the var column in the **estimates** matrix. 

    * **description** - Corresponding column to the description column in the **estimates** matrix

    * **source** - this column contains the source used to derive the variable estimates 
    
    * **type** - corresponding column to the type column in the estimates matrix 

    * **Community_safety** - This and the following are all binary columns used to subset the **estimates** matrix into broad categories of similar variables. These subsets are used in the dropdown menu of the dashboard. A 1 in this column means the row is part of the column name group, a 0 means it is not part of that group.
  
    * **Demographics** 
  
    * **Health** 
  
    * **Income_employment** 
  
    * **Education** 
  
    * **Transportation**

**`awp_shiny_helper.R`** - This code is used to load, prepare, and subset the estimates
and metadata matrices. All data visualized by the dashboard is brought into the
environment by this code. The helper preps the data by using `rbind` on the following files:

* *data/GA_2020/cleaned_acc_data.csv* **and** *data/community_data_tct.csv*
to create the tract scale **estimates** matrix

* *data/GA_2020/ESzones_acs_interpolation.csv* **and** *data/community_data_es.csv*
to create the school zone **estimates** matrix

* *data/GA_2020/metadata_all.csv* **and** *data/community_metadata.csv*
to create the complete **metadata** matrix  

**`awp_ACS_updater.R`** - This code contains a function which downloads and cleans 
5-year ACS data at the tract level from Athens-Clarke County for any given year.
This will download both the tract geometry and the data to be used by the dashboard.
This function will create a new folder in the data folder named GA_”the year you
input in the function”.  This function can be run by either loading it into the 
local environment or by defining an object named **yr** with the desired year. 

**`school_interpolate.Rmd`** - This code is used to calculate variable estimates for 
elementary school districts using the tract data downloaded by the updater. 
This code uses interpolation to determine the proportion of tract variable 
estimates to allocate to a school district when the tract crosses multiple school districts. 

**`community_vars_tct.R`** - This code is used to clean the non-ACS datasets and use
them to calculate the variables in the *community_metadata.csv* file at the tract level.
The data sources used in this code are detailed below. All datasets were first 
geocoded and then the tract id (GEOID) and Elementary School District (School) 
was determined using a join by location in QGIS. 

**`community_vars_es.R`** -  This is a nearly identical code as the one above except 
that it groups the data by School rather than by GEOID. 

**`business_distances.Rmd`** - this code is used to calculate the weighted average 
distance for tracts and school districts by calculating the distance between 
census block centroid and the three nearest businesses of a given type. The code
uses a nearest neighbor function to find the closest businesses to the block 
centroid and then uses total population of the block weight to each block and 
determine an estimate for the census tract and school district.   

### Data Sources: 

**American Community Survey 5-year estimate** - Many of variables visualized by the dashboard come from the American Community Survey conducted by the US Census Bureau. For more information visit [the census buraeu website](https://www.census.gov/programs-surveys/acs).  

**Athens-Clarke County Tax Assessor Property Ownership Data 2021** (*acc-parcel_ownership.csv*) - This data set contains publicly available information about the ownership of every land parcel in Athens-Clarke county. It was compiled by the county Tax Assessor’s office and available through the [Athens-Clarke government’s open data portal](https://data-athensclarke.opendata.arcgis.com) as of July 2021. 

**Athens-Clarke County Tax Assessor Property Sales Data 2021** (*acc_homesales_1989_forward.csv*) - This dataset contains information about the property sales in Athens-Clarke county since 1989. It contains data about the price of the sale, the parcel id, and building size. It is a dataset created and managed by the Tax Assessor's office and was received upon request. 

**Athens-Clarke County Tax Assessor Appraisal Data 2022** (*acc_appraisal_values_2022.csv*) - This data set is created and managed  by the Tax Assessor's office and contains the land and improvement appraisal values for all Athens-Clarke parcels. This data was received upon request.  

**Athens-Clarke County Business Tax Division 2021** (*acc_taxfiv_business_2021.csv*) - this data set comes from the Business Occupation Tax records created by the Athens-Clarke Business Tax Division. It contains the name, address, and classification of all businesses in Athens-Clarke registered with the Business Tax Division. This data is publicly available as a PDF [here](https://www.accgov.com/138/Business-Occupation-Tax). Optical character recognition software was used to transform the PDF into a table that was then geocoded by addresses and joined by location with the tracts and school districts.  
