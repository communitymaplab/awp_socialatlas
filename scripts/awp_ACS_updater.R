library(tidyverse)
library(tidycensus)
library(sf)

 
# The followinguses the "get_acs" function in tidycensus to download and clean 5
# year ACS data using a selected year

#census_api_key("YOUR KEY HERE") # for first time use include install = TRUE)

#options(tigris_use_cache = TRUE)

#yr<-2020

awp_acs_updater <- function(yr) {
  
  dir.create(paste("data/GA_",yr,sep=""))
  
  metadata<-read_csv("data/metadata_acsvars.csv") %>%
    mutate(source = paste("American Community Survey, 5 year sample, 
                          ",yr-4,"-",yr, sep = "")) %>%
    mutate(type = "count")

  
  acs_vars<-metadata$variable
  
  df <- get_acs(geography = "tract", state = "GA",
          variable = acs_vars, year = yr, geometry = TRUE) %>%
          mutate(GEOID=as.character(GEOID)) %>%
          mutate(source = paste("American Community Survey, 5 year sample, 
                                ",yr-4,"-",yr, sep = "")) 
  
  df_data <- df %>%
    st_drop_geometry()
  
#write_csv(df_data, paste("data/GA_", yr, "/GA_acs.csv", sep = "")) #optional download of full state data
  
  acc_acs <- df_data %>%
    filter(substr(GEOID,1,5)=="13059") 

write_csv(acc_acs, paste("data/GA_", yr, "/acc_acs.csv", sep = ""))
    
  state_geom <- df %>%
    select(GEOID,NAME,geometry)
  
#st_write(state_geom, paste("data/GA_", yr, "/GA_tracts.geojson", sep = ""), delete_dsn = TRUE) #optional download of state tract geometry
  
  acc_geom <- unique(state_geom) %>%
    filter(substr(GEOID,1,5)== "13059")%>%
    mutate(GEOID=as.character(GEOID)) %>%
    st_transform(4326)

st_write(acc_geom, paste("data/GA_",yr,"/acc_tracts.geojson", sep = ""), 
                         delete_dsn = TRUE) # ACC tracts

es_zones <- st_read("data/acc_es_zones.geojson")
 
  tct_int_es <- acc_geom %>%
    st_intersection(es_zones) 
  
  acc_tct_es <- data.frame(area = as.numeric(st_area(tct_int_es))) %>%
    bind_cols(tct_int_es) %>%
    select(-geometry) %>%
    filter(area > 116000) %>%
    group_by(GEOID, NAME) %>%
    summarise(School = paste(School, collapse = ", "))

st_write(acc_geom %>%
           left_join(acc_tct_es), paste("data/GA_",yr,"/tracts_int_eszones.geojson", sep = ""),
                                        delete_dsn = TRUE) # ACC tracts intersected with elementary school zones
  
  acc_acs_sum <- acc_acs %>%
    select(-source) %>%
    left_join(metadata) %>%
    group_by(GEOID,var_group) %>%
    summarise(
      est=sum(estimate),
      moe=round(sqrt(sum(moe^2)),0),
      )
  
  metadata_group <- metadata %>%
    select(var_group,var_normalize) 
 
  census_data<-acc_acs_sum %>%
    left_join(metadata_group) %>%
    unique()
  
  normal_vars<-census_data %>%
    filter(var_normalize=="99999") %>%
    select(GEOID,var_group,est) %>%
    rename("var_normalize"=var_group,
           "normal_est"=est)
    
  census_data_calc <- census_data %>%
    filter(var_normalize!="99999") %>%
    left_join(normal_vars) %>%
    filter(normal_est>0) %>% 
    mutate(est_pct=round(est/normal_est*100,2),
           moe_pct=round(moe/normal_est*100,2)) %>%
    select(-var_normalize,-normal_est)
  
  census_data_pct_only <-census_data_calc %>%
    select(GEOID,var_group,est_pct,moe_pct) %>%
    mutate(var_group=paste(var_group,"_p",sep="")) %>%
    rename("est"=est_pct,
           "moe"=moe_pct) %>%
    mutate(type = "pct")
  
  census_data_est_only <-census_data_calc %>%
    select(GEOID,var_group,est,moe) %>%
    mutate(type = "count")
  
  census_data_tot_only <- census_data %>%
    filter(var_normalize=="99999") %>%
    select(GEOID, var_group, est, moe) %>%
    mutate(type = "count")
  
  census_data_all<-rbind(census_data_est_only,census_data_pct_only,census_data_tot_only)
  
  census_data_all_long<-rbind(census_data_est_only,census_data_pct_only) %>% #just use census_data_all?
    rename("var"=var_group) %>%
    gather(est:moe,key="var_type",value="value")
  #  filter(substr(GEOID,1,5)=="13059")

write_csv(census_data_all_long, paste("data/GA_", yr,"/long_acc_tractdata.csv", sep = ""))
  
  metadata_p <- metadata %>%
    mutate(desc_group = paste("Percent", desc_group, sep = " ")) %>%
    mutate(var_group = paste(var_group, "_p", sep = "")) %>%
    filter(var_normalize!="99999") %>%
    mutate(type = "pct")
  
  metadata_all <- rbind(metadata, metadata_p)

write_csv(metadata_all,paste("data/GA_",yr,"/metadata_all.csv", sep = "")) # full metadata with updated sourcing
  
  meta_desc_p <- metadata_p %>%
    select(var_group, desc_group) %>%
    group_by(var_group)
    
  meta_desc <- metadata %>%
    select(var_group, desc_group) %>%
    group_by(var_group)
  
  meta_desc_all <- rbind(meta_desc, meta_desc_p) %>%
    unique()
  
  acc_census_data <- left_join(census_data_all, meta_desc_all) %>%
    rename("var" = var_group) %>%
    rename("description" = desc_group) %>%
    mutate(source = paste("American Community Survey, 5 year sample, ",yr-4,"-",yr, sep = "")) %>%
    mutate(GEOID=as.character(GEOID))
    
 # acc_census_data <- state_census_data %>%
  #  filter(substr(GEOID,1,5)=="13059")
  
write_csv(acc_census_data,paste("data/GA_",yr,"/cleaned_acc_data.csv", sep = "")) # cleaned ACC data
  
  
}

#awp_acs_updater(2020)
