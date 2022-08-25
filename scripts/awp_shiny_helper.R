library(shiny)
library(leaflet)
library(sf)
library(tidyverse)
library(readr)

districts<-st_read("data/GA_2020/tracts_int_eszones.geojson") %>% 
  select(GEOID, NAME, School) %>%
  mutate(GEOID=as.character(GEOID)) %>%
  st_transform(4326) 

acc_tracts <- st_read("data/GA_2020/acc_tracts.geojson")%>%
  st_transform(4326) 

es_zones <- st_read("data/acc_es_zones.geojson") %>%
  st_transform(4326) 

atlasdata_acs <-read_csv("data/GA_2020/cleaned_acc_data.csv") 

atlasdata_comm <- read_csv("data/community_data_tct.csv")

atlasdata <-  rbind(atlasdata_comm, atlasdata_acs) %>%
  mutate(est = round(est, digits = 2)) %>%
  mutate(moe = round(moe, digits = 2)) %>%
  mutate(GEOID=as.character(GEOID))

acs_es <- read_csv("data/GA_2020/ESzones_acs_interpolation.csv") %>%
  select(-SchoolID)

comm_es <- read_csv("data/community_data_es.csv") 

atlasdata2 <- rbind(acs_es, comm_es) %>%
  mutate(moe = 0) %>%
  mutate(est = round(est, digits = 2))


########################################
#####Loading the metadata variables#####
########################################
#PURPOSE: This metadata will be used to show the source of each variable. In addition, the metadata will be used
#for the dynamic loading of the variables in each of the domains.

metadata1 <-read_csv("data/GA_2020/metadata_all.csv") %>% 
  select(var_group:type, -popup_lab) %>%
  rename("variable"=var_group,
         "description"=desc_group) %>%
  unique()

metadata2 <- read_csv("data/community_metadata.csv") 

metadata <- bind_rows(metadata2,metadata1) %>%
  unique()

###############################################
#####Subsetting the data based on category#####
###############################################

#NOTE: First I subsetted the data based on category. After that, I make sure to sort all the variables in that category
#in ascending order and remove duplicate fields.

#safety variables
safetyvariables <-subset(metadata, Community_safety == 1)
select_safety <- sort(unique(safetyvariables$description))

#demographic variables
demovariables <- subset(metadata, Demographics == 1)
select_demo <- unique(demovariables$description)
select_demo_count<-select_demo[grep("Percent",select_demo,invert=TRUE)]
select_demo_pct<-select_demo[grep("Percent",select_demo)]

#health variables
healthvariables <-subset(metadata, Health == 1)
select_health <- unique(healthvariables$description)
select_health_count<-select_health[grep("Percent",select_health,invert=TRUE)]
select_health_pct<-select_health[grep("Percent",select_health)]

#housing variables
housingvariables <-subset(metadata, Housing == 1)
select_housing <- unique(housingvariables$description)
select_housing_count<-select_housing[grep("Percent",select_housing,invert=TRUE)]
select_housing_pct<-select_housing[grep("Percent",select_housing)]

#income and employment variables
incemployvariables <-subset(metadata, Income_employment == 1)
select_incemploy <- unique(incemployvariables$description)
select_incemploy_count<-select_incemploy[grep("Percent",select_incemploy,invert=TRUE)]
select_incemploy_pct<-select_incemploy[grep("Percent",select_incemploy)]

#education variables
eduvariables <- subset(metadata, Education == 1)
select_edu <- unique(eduvariables$description)
select_edu_count<-select_edu[grep("Percent",select_edu,invert=TRUE)]
select_edu_pct<-select_edu[grep("Percent",select_edu)]

#transportation variables
transvariables <- subset(metadata, Transportation == 1)
select_trans <- unique(transvariables$description)
select_trans_count<-select_trans[grep("Percent",select_trans,invert=TRUE)]
select_trans_pct<-select_trans[grep("Percent",select_trans)]
