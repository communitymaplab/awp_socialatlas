library(tidyverse)
library(sf)
library(tidycensus)


#Load school zones
elemzone<-st_read("data/acc_es_zones.geojson") %>%
  select(SchoolID,School)

#Load blocks and join to school zones
#Tract IDs are already part of the block fips (first 11 characters)
blocks<-st_read("data/accblocks20_totalpop.gpkg") %>%
  mutate(totalpop=as.numeric(U7C001),
         fips_tct=substr(GEOID20,1,11)) %>%
  st_join(elemzone,join=st_within)

#Calculate block populations in each school zone/tract combination
#Then sum total tract population and calculate the percentage of each zone/tract area
tract_es<-blocks %>%
  st_set_geometry(NULL) %>%
  group_by(fips_tct,SchoolID,School) %>%
  summarise(estct_pop=sum(totalpop)) %>% #Sum the block population for each zone/tract combo
  group_by(fips_tct) %>% #Group by tract
  mutate(tct_pop=sum(estct_pop), #Calculate the total tract population
         popratio=round(estct_pop/tct_pop,4)) %>% #Calculate the ratio of each zone/tract combo to the total tract pop
  filter(popratio>0)

#Save the result
write_csv(tract_es,"data/eszones_tract_crosswalk_2020.csv")
