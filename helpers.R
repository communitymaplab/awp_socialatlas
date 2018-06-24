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
#Read and select census polygons#
#################################
districts<-st_read("app_old/ElementarySchoolDistricts_data.shp") %>%
  select(SchoolID, ES_short) 


################################################################################################
#####Loading the data and Changing the fields in the Atlas Data so these variables can work#####
################################################################################################
atlasdata<-read_csv("data/AthensSocialAtlasData_2018_04_23.csv")
atlasdata$description[atlasdata$var == "Age05.y16"] <- "Age under 5 years"
atlasdata$description[atlasdata$var == "Age18_24.y16"] <- "Age 18-24 years"
atlasdata$description[atlasdata$var == "AgeO65.y16"] <- "Age 65 and older"
atlasdata$description[atlasdata$var == "AgeU18.y16"] <- "Age under 18 years"
atlasdata$description[atlasdata$var == "Rce_AI.y16"] <- "American Indian/non-hispanic population"
atlasdata$description[atlasdata$var == "Rce_AsnNH.y16"] <- "Asian non-hispanic population"
atlasdata$description[atlasdata$var == "Rce_BlkNH.y16"] <- "Black non-hispanic population"
atlasdata$description[atlasdata$var == "Rce_HPI.y16"] <- "Hawaiian/Pacific Islander population"
atlasdata$description[atlasdata$var == "Rce_Hisp.y16"] <- "Hispanic/latinx population"
atlasdata$description[atlasdata$var == "Rce_OthNH.y16"] <- "Other race non-hispanic"
atlasdata$description[atlasdata$var == "Pov_Ov65.y16"] <- "Poverty over 65"
atlasdata$description[atlasdata$var == "Pov_Und18.y16"] <- "Poverty under 18"
atlasdata$description[atlasdata$var == "HousUnits.y16"] <- "Total housing units"
atlasdata$description[atlasdata$var == "TotPop.y16"] <- "Total population"
atlasdata$description[atlasdata$var == "Rce_WhtNH.y16"] <- "White non-hispanic population" 
#For the Healthy People & Environments domain
atlasdata$description[atlasdata$var == "HInsur_FBNat.y16"] <- "Has health insurance foreign born and naturalized"
atlasdata$description[atlasdata$var == "HInsur_FBNC.y16"] <- "Has health insurance foreign born non-citizen"
atlasdata$description[atlasdata$var == "HInsur_Nat.y16"] <- "Has health insurance native born"
#For the Housing domain
atlasdata$description[atlasdata$var == "Rent30.y16"] <- "Population whose gross rent is >30% of income"
atlasdata$description[atlasdata$var == "HousOwn.y16"] <- "Total population in owner occupied housing"
atlasdata$description[atlasdata$var == "HousRent.y16"] <- "Total population in renter occupied housing"
#Income & Employment
atlasdata$description[atlasdata$var == "Inc10K_24K.y16"] <- "Houshold income $10,000 - $24,999"
atlasdata$description[atlasdata$var == "Inc100K_149K.y16"] <- "Houshold income $100,000 - $149,999"
atlasdata$description[atlasdata$var == "Inc150K_199K.y16"] <- "Houshold income $150,000 - $199,999"
atlasdata$description[atlasdata$var == "Inc25K_49K.y16"] <- "Houshold income $25,000 - $49,999"
atlasdata$description[atlasdata$var == "Inc50K_74K.y16"] <- "Houshold income $50,000 - $74,999"
atlasdata$description[atlasdata$var == "Inc75K_99K.y16"] <- "Houshold income $75,000 - $99,999"
atlasdata$description[atlasdata$var == "Inc_10K.y16"] <-"Houshold income < $10,000"
atlasdata$description[atlasdata$var == "Inc_200K.y16"] <- "Houshold income > $200,000"
atlasdata$description[atlasdata$var == "Ind_arts.y16"] <- "Population employed in arts, entertainment, and recreation"
atlasdata$description[atlasdata$var == "Ind_const.y16"] <- "Population employed in construction"
atlasdata$description[atlasdata$var == "Ind_edhlth.y16"] <- "Population employed in educational services, health care, or social assistance"
atlasdata$description[atlasdata$var == "Ind_finan.y16"] <- "Population employed in finance, insurance, and real estate"
atlasdata$description[atlasdata$var == "Ind_info.y16"] <- "Population employed in information"
atlasdata$description[atlasdata$var == "Ind_manf.y16"] <- "Population employed in manufacturing"
atlasdata$description[atlasdata$var == "Ind_other.y16"] <- "Population employed in other services"
atlasdata$description[atlasdata$var == "Ind_prof.y16"] <- "Population employed in professional, scientific and management, administration, or waste services" 
atlasdata$description[atlasdata$var == "Ind_pubad.y16"] <- "Population employed in public administration"
atlasdata$description[atlasdata$var == "Ind_retail.y16"] <- "Population employed in retail"
atlasdata$description[atlasdata$var == "Ind_trans.y16"] <- "Population employed in transportation, warehousing, and utilites" 
atlasdata$description[atlasdata$var == "Ind_whlsl.y16"] <- "Population employed in wholesale trade"
atlasdata$description[atlasdata$var == "Ind_ag.y16"] <- "Total population for ag forestry fishing and hunting"
atlasdata$description[atlasdata$var == "Empl_unemp.y16"] <- "Total population unemployed"
#Lifelong learning variables
atlasdata$description[atlasdata$var == "Ed_ba.y16"] <- "Bachelor's degree"
atlasdata$description[atlasdata$var == "Ed_hsgrad.y16"] <- "High school diploma or GED"
atlasdata$description[atlasdata$var == "Ed_lesshs.y16"] <- "Less than high school graduate"
atlasdata$description[atlasdata$var == "Ed_ma.y16"] <- "MA degree"
atlasdata$description[atlasdata$var == "Ed_prof_doc.y16"] <- "Professional/doctorate degree"
atlasdata$description[atlasdata$var == "Ed_somecol.y16"] <- "Some college or Associate's Degree"
atlasdata$description[atlasdata$var == "Sch_Kpre.y16"] <- "Total enrolled in nursery school & kindergarten"
atlasdata$description[atlasdata$var == "Sch_grad.y16"] <- "Total in grad school"
atlasdata$description[atlasdata$var == "Sch_ugrad.y16"] <- "Total in undergraduate"
#transportation variables
atlasdata$description[atlasdata$var == "Trn_carpool.y16"] <- "Commute: carpooled in car"
atlasdata$description[atlasdata$var == "Trn_noveh.y16"] <- "Commute: no available vehicle"
atlasdata$description[atlasdata$var == "Trn_taxi.y16"] <- "Commute: other--taxi, motorcycle, or bicycle"
atlasdata$description[atlasdata$var == "Trn_car.y16"] <- "Commute: used car, truck, or van alone"
atlasdata$description[atlasdata$var == "Trn_pub.y16"] <- "Commute: used public transit"
atlasdata$description[atlasdata$var == "Trn_home.y16"] <- "Commute: Worked at home"
atlasdata$description[atlasdata$var == "Trn_walk.y16"] <- "Walked to work"


########################################
#####Loading the metadata variables#####
########################################
#PURPOSE: This metadata will be used to show the source of each variable. In addition, the metadata will be used
#for the dynamic loading of the variables in each of the domains.
metadata<-read_csv("data/AthensSocialAtlasData_metadata_2018_02_05.csv")
#####Changing the fields in the metadata to change an error in the demographic variables#####
metadata$description[metadata$variable == "AgeO65"] <- "Age 65 and older"
metadata$description[metadata$variable == "Rce_BlkNH"] <- "Black non-hispanic population"
#removing variables in the metadata
metadata <- metadata[!(metadata$variable == "Pov_pop"),]
metadata <- metadata[!(metadata$variable == "HousUnits"),]
metadata <- metadata[!(metadata$variable == "HousPop"),]


########################################
#####Loading the Middle School data#####  
########################################
#NOTE: As of June 2018, this part of the app is not done. The data still needs to be added. However, we can still
#load the geojson and join the data later.
ms <- st_read("data/MiddleSchoolDistrictsWGS84.geojson")
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
