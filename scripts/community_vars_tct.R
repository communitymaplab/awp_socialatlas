# calculating community variables

library(readr)
library(tidyverse)


# import and prep parcel ownership data and community metadata

community_metadata <- read_csv("data/community_metadata.csv")

parcels_data_raw <- read_csv("data/acc_parcel_ownership.csv", 
                             col_types = cols(GEOID = col_character())) 

parcels_data <- parcels_data_raw %>%
  na.omit()
  
atl_msa_places <- read_csv("data/atl_msa_places.csv")

##id parcels owned in atl msa 

atl_msa_places$CITY = toupper(atl_msa_places$NAME)

atl_msa <- atl_msa_places %>%
  mutate(STATE = "GA") %>%
  merge(parcels_data, by = c("CITY", "STATE"), all.x = FALSE, all.y = FALSE) 

atl_join <- atl_msa %>%
  select(PARCEL_NO, OBJECTID) %>%
  mutate(OWN_IN_ATLMSA = 1) 

parcels_data <- parcels_data %>%
  left_join(atl_join) %>%
  mutate_at(21, ~replace_na(.,0))

## Total parcels and square footage 

total_property <- parcels_data %>%
  group_by(GEOID) %>%
  summarise(tot_parcs = n()) %>%
  mutate(var = "tot_parcels")

total_land <- parcels_data %>%
  group_by(GEOID) %>%
  summarise(tot_land = sum(AREA)) %>%
  mutate(var = "tot_land")

## Owned in Athens-Clarke County

parcels_owned_acc <- parcels_data %>%
  group_by(GEOID) %>%
  summarise(parcs_own_acc = sum(OWN_IN_ACC))

parcels_owned_acc_p <- parcels_data %>%
  group_by(GEOID) %>%
  summarise(pct_parcs_own_acc = round(sum(OWN_IN_ACC)/n()*100, digits = 0)) %>%
  mutate(var = "par_own_acc_p") %>%
  rename("est" = pct_parcs_own_acc)

land_owned_acc <- parcels_data %>%
  group_by(GEOID) %>%
  filter(OWN_IN_ACC == 1) %>%
  summarise(land_own_acc = sum(AREA))

land_owned_acc_p <- land_owned_acc %>%
  mutate(pct_land_own_acc = round((land_own_acc/total_land$tot_land) * 100, digits = 0)) %>%
  select(-land_own_acc) %>%
  mutate(var = "land_own_acc_p") %>%
  rename("est" = pct_land_own_acc)

## Owned in GA 

parcels_owned_ga <- parcels_data %>%
  group_by(GEOID) %>%
  summarise(parcs_own_ga = sum(OWN_IN_GA))

parcels_owned_ga_p <- parcels_data %>%
  group_by(GEOID) %>%
  summarise(pct_parcs_own_ga = round(sum(OWN_IN_GA)/n()*100, digits = 0)) %>%
  mutate(var = "par_own_ga_p") %>%
  rename("est" = pct_parcs_own_ga)

land_owned_ga <- parcels_data %>%
  group_by(GEOID) %>%
  filter(OWN_IN_GA == 1) %>%
  summarise(land_own_ga = sum(AREA))

land_owned_ga_p <- land_owned_ga %>%
  mutate(land_own_ga_p = round((land_own_ga/total_land$tot_land) * 100, digits = 0)) %>%
  select(-land_own_ga) %>%
  mutate(var = "land_own_ga_p") %>%
  rename("est" = land_own_ga_p)

## Owned in Atlanta Metropolitan Statistical Area 

parcels_owned_atl <- parcels_data %>%
  group_by(GEOID) %>%
  summarise(par_own_us = sum(OWN_IN_ATLMSA))

parcels_owned_atl_p <- parcels_data %>%
  group_by(GEOID) %>%
  summarise(par_own_atl_p = round(sum(OWN_IN_ATLMSA)/n()*100, digits = 0)) %>%
  mutate(var = "par_own_atl_p") %>%
  rename("est" = par_own_atl_p)

land_owned_atl <- parcels_data %>%
 group_by(GEOID) %>%
 filter(OWN_IN_ATLMSA == 1) %>%
 summarise(land_own_atl = sum(AREA))

land_owned_atl_p <- land_owned_atl %>%
  mutate(land_own_atl_p = round((land_own_atl/total_land$tot_land) * 100, digits = 0)) %>%
  select(-land_own_atl) %>%
  mutate(var = "land_own_atl_p") %>%
  rename("est" = land_own_atl_p)

### prep ownership data for dashboard   

parcels_ownership <- rbind(parcels_owned_acc_p,
                       land_owned_acc_p,
                       parcels_owned_ga_p,
                       land_owned_ga_p,
                       parcels_owned_atl_p, 
                       land_owned_atl_p)

# load and prep property sales data 

propsales_raw <- read_csv("data/acc_homesales_1989_forward.csv", 
                              col_types = cols(HEATEDAREA = col_double()))

sales_data <- propsales_raw %>%
  merge(parcels_data) %>%
  select(PARCEL_NO, YEAR, SALEPRICE, SchoolID, School, GEOID, HEATEDAREA, AREA) %>%
  filter(!SALEPRICE < 10, YEAR >= 2000, !YEAR == 2022, !YEAR == "NULL", !HEATEDAREA == 0) %>%
  mutate(bldg_ppsqft = SALEPRICE/HEATEDAREA)

## create mean and median variables by year and tract

avg_ppsqft_year <- sales_data %>%
  group_by(YEAR, GEOID) %>%
  summarise(avg_bldg_ppsqft = mean(bldg_ppsqft))

avg_saleprice_year <- sales_data %>%
  group_by(YEAR, GEOID) %>%
  summarise(avg_prop_saleprice = mean(SALEPRICE))

med_ppsqft_year <- sales_data %>%
  group_by(YEAR, GEOID) %>%
  summarise(med_bldg_ppsqft = median(bldg_ppsqft))

med_saleprice_year <- sales_data %>%
  group_by(YEAR, GEOID) %>%
  summarise(med_prop_saleprice = median(SALEPRICE))

## Calculating change in mean and median sales price per square foot between 2000-2020 and 2010-2020

avg_ppsqft_2000 <- avg_ppsqft_year %>%
  filter(YEAR == 2000) %>%
  rename("avg_bldg_ppsqft_2000" = avg_bldg_ppsqft)

avg_ppsqft_2010 <- avg_ppsqft_year %>%
  filter(YEAR == 2010)%>%
  rename("avg_bldg_ppsqft_2010" = avg_bldg_ppsqft)

avg_ppsqft_2020 <- avg_ppsqft_year %>%
  filter(YEAR == 2020) %>%
  rename("avg_bldg_ppsqft_2020" = avg_bldg_ppsqft)

avg_ppsqft_change <- avg_ppsqft_2000 %>%
  left_join(avg_ppsqft_2010, by = "GEOID") %>%
  left_join(avg_ppsqft_2020, by = "GEOID") %>%
  mutate(avg_change_2000to2020 = avg_bldg_ppsqft_2020 - avg_bldg_ppsqft_2000) %>%
  mutate(avg_change_2000to2020_p = (avg_change_2000to2020/avg_bldg_ppsqft_2000)*100) %>%
  mutate(avg_change_2010to2020 = avg_bldg_ppsqft_2020 - avg_bldg_ppsqft_2010) %>%
  mutate(avg_change_2010to2020_p = (avg_change_2010to2020/avg_bldg_ppsqft_2010)*100) %>%
  select(-YEAR, -YEAR.x, -YEAR.y)

med_ppsqft_2000 <- med_ppsqft_year %>%
  filter(YEAR == 2000) %>%
  rename("med_bldg_ppsqft_2000" = med_bldg_ppsqft)

med_ppsqft_2010 <- med_ppsqft_year %>%
  filter(YEAR == 2010)%>%
  rename("med_bldg_ppsqft_2010" = med_bldg_ppsqft)

med_ppsqft_2020 <- med_ppsqft_year %>%
  filter(YEAR == 2020) %>%
  rename("med_bldg_ppsqft_2020" = med_bldg_ppsqft)

med_ppsqft_change <- med_ppsqft_2000 %>%
  left_join(med_ppsqft_2010, by = "GEOID") %>%
  left_join(med_ppsqft_2020, by = "GEOID") %>%
  mutate(med_change_2000to2020 = med_bldg_ppsqft_2020 - med_bldg_ppsqft_2000) %>%
  mutate(med_change_2000to2020_p = (med_change_2000to2020/med_bldg_ppsqft_2000)*100) %>%
  mutate(med_change_2010to2020 = med_bldg_ppsqft_2020 - med_bldg_ppsqft_2010) %>%
  mutate(med_change_2010to2020_p = (med_change_2010to2020/med_bldg_ppsqft_2010)*100) %>%
  select(-YEAR, -YEAR.x, -YEAR.y)

## prep property sales data for dashboard by creating uniform naming structure   

med_ppsqft_2020_a <- med_ppsqft_2020 %>%
  ungroup() %>%
  select(-YEAR) %>%
  mutate(var = "med_bldg_ppsqft_2020") %>%
  rename("est" = med_bldg_ppsqft_2020) 

percent_change_med_00to20 <- med_ppsqft_change %>%
  select(GEOID, med_change_2000to2020_p) %>%
  mutate(var = "med_change_2000to2020_p") %>%
  rename("est" = med_change_2000to2020_p)

percent_change_med_10to20 <- med_ppsqft_change %>%
  select(GEOID, med_change_2010to2020_p) %>%
  mutate(var = "med_change_2010to2020_p") %>%
  rename("est" = med_change_2010to2020_p)

avg_ppsqft_2020_a <- avg_ppsqft_2020 %>%
  ungroup() %>%
  select(-YEAR) %>%
  mutate(var = "avg_bldg_ppsqft_2020") %>%
  rename("est" = avg_bldg_ppsqft_2020)

percent_change_avg_00to20 <- avg_ppsqft_change %>%
  select(GEOID, avg_change_2000to2020_p) %>%
  mutate(var = "avg_change_2000to2020_p") %>%
  rename("est" = avg_change_2000to2020_p)

percent_change_avg_10to20 <- avg_ppsqft_change %>%
  select(GEOID, avg_change_2010to2020_p) %>%
  mutate(var = "avg_change_2010to2020_p") %>%
  rename("est" = avg_change_2010to2020_p)

### prep sales data for dashboard by binding tables together

sales_vars <- rbind(med_ppsqft_2020_a, percent_change_med_00to20,
                           percent_change_med_10to20, avg_ppsqft_2020_a, 
                           percent_change_avg_00to20, percent_change_avg_10to20)

# load and calculate variables with appraisal data 
  
  ## what to do with parcels in appraisal data that are not in ownership data? 
  ## what is going on with the very low appr value parcels?  

apprval_raw <- read_csv("data/ACC_apprasial_values_2022.csv") 

apprasial_data <- apprval_raw %>%
  left_join(parcels_data, by = "PARCEL_NO") %>%
  select(PARCEL_NO, OWNER_NAME, `2022 Total`, `2022 Land`, `2022 Imp`, GEOID, SchoolID, School, AREA) %>%
  rename("land_area" = AREA, "appr_total" = '2022 Total', "appr_land" = '2022 Land', "appr_imp" = '2022 Imp') %>%
  na.omit() %>%
  unique() %>%
  filter(appr_total > 1000) %>%
  mutate(land_area = round(land_area), digits = 0) 

## create totals variables grouping by tract  

appr_totals <- apprasial_data %>%
  group_by(GEOID) %>%
  mutate(geoid_apprtot = sum(appr_total)) %>%
  mutate(geoid_land = sum(land_area)) %>%
  select(GEOID, geoid_land, geoid_apprtot) %>%
  unique() %>%
  mutate(tot_ppsqft = round((geoid_apprtot/geoid_land), digits = 2))

## create mean and median variables by census tract 

appr_mean <- apprasial_data %>%
  group_by(GEOID) %>%
  summarise(avg_appr_val = mean(appr_total))

appr_median <- apprasial_data %>%
  group_by(GEOID) %>%
  summarise(med_appr_val = median(appr_total))
  
avg_appr_ppsqft <- apprasial_data %>%
  mutate(appr_ppsqft = (appr_total/land_area)) %>%
  group_by(GEOID) %>%
  summarise(avg_appr_ppsqft = mean(appr_ppsqft))

med_appr_ppsqft <- apprasial_data %>%
  mutate(appr_ppsqft = (appr_total/land_area)) %>%
  group_by(GEOID) %>%
  summarise(med_appr_ppsqft = median(appr_ppsqft)) 

## join all variable together as wide table 

appraisals_wide <- appr_mean %>%
  left_join(appr_median, by = "GEOID") %>%
  left_join(avg_appr_ppsqft, by = "GEOID") %>%
  left_join(med_appr_ppsqft, by = "GEOID")

### prep appraisal data for dashboard by pivoting the wide table longer  

appraisals_vars <- pivot_longer(appraisals_wide, avg_appr_val:med_appr_ppsqft, names_to = "var", values_to = "est")


# Athens Tax Division Data - source data is "data/acc_taxdiv_business_2021.csv" 

naics_22<- read_csv("data/naics_22.csv")

businesses <- read_csv("data/business_tax_division_2021.csv")

### business_distances.rmd in the "Scripts" folder to calculate weighted average 
### distances to the closest three business types by NAICS code 

## select and clean naics codes

business_distances <- read_csv("data/accnaics_distances_tct.csv")

business_distances_wide <- read_csv("data/accnaics_distances_tct_wide.csv")

bus_dist_data <- business_distances_wide %>%
  select("tct_fips", "CONVENIENCE STORES", "SUPERMARKETS AND OTHER GROCERY (EXCEPT CONVENIENCE)",
         "OFFICE OF PHYSICIANS (EXCEPT MENTAL HEALTH SPECIALISTS)","OFFICES OF MENTAL HEALTH PRACTITIONERS (EXCEPT PHYSICIANS)",
         "OFFICES OF DENTISTS", "PHARMACIES AND DRUG RETAILERS", "FITNESS AND RECREATIONAL SPORTS CENTERS",
         "CHILD DAY CARE SERVICES", "REAL ESTATE PROPERTY MANAGERS", "OFFICES OF LAWYERS", "NON-PROFIT ORGANIZATION",
         "NEW AND USED CAR DEALERS", "AUTO REPAIR AND MAINTENANCE") %>%
  rename("GEOID" = tct_fips) #%>%
  #mutate(super_con_ratio = `SUPERMARKETS AND OTHER GROCERY (EXCEPT CONVENIENCE)`/`CONVENIENCE STORES`)

bus_dist_vars <- pivot_longer(bus_dist_data, 'CONVENIENCE STORES':'AUTO REPAIR AND MAINTENANCE', names_to = "var", values_to = "est")
  

# bind all community variables into a single table and join with community metadata

community_metadata <- community_metadata %>%
  select(-c(Community_safety:Transportation)) %>%
  rename("var" = variable)
    
community_data <- rbind (sales_vars, parcels_ownership, appraisals_vars, bus_dist_vars) %>%
                  left_join(community_metadata, by = "var") %>%
                  mutate(moe = 0) 

write_csv(community_data, "data/community_data_tct.csv")


  

