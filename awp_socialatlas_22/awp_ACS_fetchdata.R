library(tidyverse)
library(tidycensus)
library(sf)

 
# The following "pull_acs" function uses the "get_acs" function in tidycensus and the code 
# from "ACS_walkthrough" to pull and clean Census data using a selected set of inputs and variables.
# This tool will pull data from the year selected and create a new folder with the following files 
# for use with the "AWB_shiny_app":
 
 
# The inputs below correspond to their use as arguments in the "get_acs" function: 


# yr = The year, or endyear, of the ACS sample. 5-year ACS data is available 
## from 2009 through 2020;
es_zones <- st_read("data/acc_es_zones.geojson")

options(tigris_use_cache = TRUE)

awp_acs_updater <- function(yr)
  {
  dir.create(paste("data/GA_",yr,sep=""))
  
  metadata<-read_csv("data/metadata_acsvars.csv") %>%
    select(-source, -year_last_updated) %>%
    mutate(source = paste("American Community Survey, 5 year sample, ",yr-4,"-",yr, sep = ""))

  acs_vars<-metadata$variable
  
  df <- get_acs(geography = "tract", state = "GA",
          variable = acs_vars, year = yr, geometry = TRUE) %>%
          mutate(GEOID=as.character(GEOID)) %>%
          mutate(source = paste("American Community Survey, 5 year sample, ",yr-4,"-",yr, sep = "")) 
  
  df_data <- df %>%
    st_drop_geometry()
  
#write.csv(df_data, "data/GA_2020/GA_census.csv") #optional download of full state data
  
  state_geom <- df %>%
    select(GEOID,NAME,geometry)
  
#st_write(state_geom, "data/GA_2020/GA_tracts.geojson", delete_dsn = TRUE) #optional download of state tract geometry
  
  state_geom <- unique(state_geom) %>%
    filter(substr(GEOID,1,5)== "13059") 
  
  acc_geom1 <- state_geom %>%
    mutate(GEOID=as.character(GEOID)) %>%
    st_transform(4326)  

st_write(acc_geom1, paste("data/GA_",yr,"/acc_tracts.geojson", sep = ""), delete_dsn = TRUE) # ACC tracts

  acc_geom2 <- acc_geom1 %>%
    st_intersection(es_zones) 
  
  acc_geom3 <- data.frame(area = as.numeric(st_area(acc_geom2))) %>%
    bind_cols(acc_geom2) %>%
    select(-geometry) %>%
    filter(area > 116000) %>%
    group_by(GEOID, NAME) %>%
    summarise(School = paste(School, collapse = ", "))

st_write(state_geom %>%
           left_join(acc_geom3), paste("data/GA_",yr,"/tracts_int_eszones.geojson", sep = ""), delete_dsn = TRUE) # ACC tracts intersected with elementary school zones
  
  df_data <- df_data %>%
    left_join(metadata) %>%
    group_by(GEOID,var_group) %>%
    summarise(
      est=sum(estimate),
      moe=round(sqrt(sum(moe^2)),0),
      )
  
  metadata_group <- metadata %>%
    select(var_group,var_normalize)
  
  census_data<-df_data %>%
    left_join(metadata_group) %>%
    unique()
  
  normal_vars<-census_data %>%
    filter(var_normalize=="99999") %>%
    select(GEOID,var_group,est) %>%
    rename("var_normalize"=var_group,
           "normal_est"=est)
    
  census_data_pct <- census_data %>%
    filter(var_normalize!="99999") %>%
    left_join(normal_vars) %>%
    filter(normal_est>0) %>% 
    mutate(est_pct=round(est/normal_est*100,2),
           moe_pct=round(moe/normal_est*100,2)) %>%
    select(-var_normalize,-normal_est)
  
  census_data_pct_only <-census_data_pct %>%
    select(GEOID,var_group,est_pct,moe_pct) %>%
    mutate(var_group=paste(var_group,"_p",sep="")) %>%
    rename("est"=est_pct,
           "moe"=moe_pct)
  
  census_data_est_only <-census_data_pct %>%
    select(GEOID,var_group,est,moe)
  
  census_data_tot_only <- census_data %>%
    filter(var_normalize=="99999") %>%
    select(GEOID, var_group, est, moe)
  
  census_data_all<-rbind(census_data_est_only,census_data_pct_only,census_data_tot_only)
  
  metadata_p <- metadata %>%
    mutate(desc_group = paste("Percent", desc_group, sep = " ")) %>%
    mutate(var_group = paste(var_group, "_p", sep = "")) %>%
    filter(var_normalize!="99999")
  
  metadata_all <- rbind(metadata, metadata_p)

write.csv(metadata_all,paste("data/GA_",yr,"/metadata_all.csv", sep = ""), row.names = FALSE) # full metadata with updated sourcing
  
  meta_desc_p <- metadata_p %>%
    select(var_group, desc_group) %>%
    group_by(var_group)
    
  meta_desc <- metadata %>%
    select(var_group, desc_group) %>%
    group_by(var_group)
  
  meta_desc_all <- rbind(meta_desc, meta_desc_p) %>%
    unique()
  
  state_census_data <- left_join(census_data_all, meta_desc_all) %>%
    rename("var" = var_group) %>%
    rename("description" = desc_group) %>%
    mutate(source = paste("American Community Survey, 5 year sample, ",yr-4,"-",yr, sep = "")) %>%
    mutate(GEOID=as.character(GEOID))
    
  acc_census_data <- state_census_data %>%
    filter(substr(GEOID,1,5)=="13059")
  
write_csv(acc_census_data,paste("data/GA_",yr,"/cleaned_acc_data.csv", sep = "")) # cleaned ACC data
  
  
  }



