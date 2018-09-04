##This is the helper file that will be loaded once the app initializes. The purpose of this app is to do some background 
##processes such as changing the name of some fields, joining data to shapefiles, and so on.

###################################
#These libraries need to be loaded#
###################################
library(shiny)
library(leaflet)
library(sf)
library(tidyverse)
library(readr)


#################################
#Read and select elementary school zone polygons#
#################################
districts<-st_read("data/AWP_shinydata.gpkg",layer="es_zones") %>%
  select(SchoolID, School) 

################################################################################################
#####Loading the data and Changing the fields in the Atlas Data so these variables can work#####
################################################################################################
atlasdata1<-st_read("data/AWP_shinydata.gpkg",layer="acsdata_2016") %>%
  st_set_geometry(NULL) %>%
  distinct
atlasdata2<-st_read("data/AWP_shinydata.gpkg",layer="community_data") %>%
  st_set_geometry(NULL) 

atlasdata<-bind_rows(atlasdata1,atlasdata2)

########################################
#####Loading the metadata variables#####
########################################
#PURPOSE: This metadata will be used to show the source of each variable. In addition, the metadata will be used
#for the dynamic loading of the variables in each of the domains.
metadata1<-read_csv("data/metadata_acsvars.csv") %>% 
  select(-var_name:-var_normalize) %>%
  rename("variable"=var_group,
         "description"=desc_group)
metadata2<-read_csv("data/metadata_communityvars.csv") 

metadata<-bind_rows(metadata2,metadata1) %>%
  filter(!variable %in% c("Pov_pop","HousUnits","HousPop")) %>%
  distinct

metadata_download<-metadata %>%
  select(variable,description,source,year_last_updated)
write_csv(metadata_download,"data/metadata_public.csv")

########################################
#####Loading the Middle School data#####  
########################################
#NOTE: As of June 2018, this part of the app is not done. The data still needs to be added. However, we can still
#load the geojson and join the data later.
ms <- st_read("data/AWP_shinydata.gpkg",layer="ms_zones")
#renaming the columns so there's no issue with joining the data.
middleschool <- ms %>% 
  rename("Mschool" = "MS_Short")
#I am going to rename "Clarke" to "Clarke Middle" so there's not issues with joining the data.
levels(middleschool$Mschool)[levels(middleschool$Mschool) == "Clarke"] <- "Clarke Middle"


###############################################
#####Subsetting the data based on category#####
###############################################
#NOTE: First I subsetted the data based on category. After that, I make sure to sort all the variables in that category
#in ascending order and remove duplicate fields.
#safety variables
safetyvariables <-subset(metadata, Community_safety == 1)
select_safety <- sort(unique(safetyvariables$description))
#demographic variables
demovariables <-subset(metadata, Demographics == 1)
select_demo <- sort(unique(demovariables$description))
#health variables
healthvariables <-subset(metadata, Health == 1)
select_health <- sort(unique(healthvariables$description))
#housing variables
housingvariables <-subset(metadata, Housing == 1)
select_housing <- sort(unique(housingvariables$description))
#income and employment variables
incemployvariables <-subset(metadata, Income_employment == 1)
select_incemploy <- sort(unique(incemployvariables$description))
#education variables
eduvariables <- subset(metadata, Education == 1)
select_edu <- sort(unique(eduvariables$description))
#transportation variables
transvariables <- subset(metadata, Transportation == 1)
select_trans <- sort(unique(transvariables$description))
