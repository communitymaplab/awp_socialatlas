library(shiny)
library(leaflet)
library(sf)
library(tidyverse)
library(readr)

districts<-st_read("data/GA_2020/tracts_int_eszones.geojson") %>% 
  select(GEOID, NAME, School) %>%
  mutate(GEOID=as.character(GEOID))%>%
  st_transform(4326) 

acc_tracts <- st_read("data/GA_2020/acc_tracts.geojson")%>%
  st_transform(4326) 

es_zones <- st_read("data/acc_es_zones.geojson") %>%
  st_transform(4326) 

atlasdata <-read.csv("data/GA_2020/cleaned_acc_data.csv") %>%
  select(GEOID, var, est, description, moe) %>%
  mutate(est = round(est, digits = 0)) %>%
  mutate(moe = round(moe, digits = 0)) %>%
  #mutate(moe=0) %>%
  #filter(str_detect(var, "_p$")) %>%
  #mutate(var = gsub("_p$","",var)) %>%
  #mutate(description = gsub("^Percent ","",description)) %>%
  mutate(GEOID=as.character(GEOID)) %>%
  distinct

atlasdata2<-read.csv("data/GA_2020/ESzones_acs_interpolation.csv") %>%
  select(-"X")

#atlasdata2<-st_read("data/AWP_shinydata.gpkg",layer="community_data") %>%
  #st_set_geometry(NULL) 

#atlasdata<-bind_rows(atlasdata1,atlasdata2)


########################################
#####Loading the metadata variables#####
########################################
#PURPOSE: This metadata will be used to show the source of each variable. In addition, the metadata will be used
#for the dynamic loading of the variables in each of the domains.

metadata<-read_csv("data/GA_2020/metadata_all.csv") %>% #replace 2020 with new year to update
  select(-var_name:-var_normalize) %>%
  rename("variable"=var_group,
         "description"=desc_group) %>%
  #filter(!variable %in% c("Pov_pop","HousUnits","HousPop")) %>%
  distinct

#metadata2<-read_csv("data/metadata_communityvars.csv") 

#metadata<-bind_rows(metadata2,metadata1) %>%
 # filter(!variable %in% c("Pov_pop","HousUnits","HousPop")) %>%
  #distinct

metadata_download<-metadata %>%
  select(variable,description,source)
write_csv(metadata_download,"data/GA_2020/metadata_public.csv")

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
