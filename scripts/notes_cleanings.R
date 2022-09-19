# leaflet labelFormat function to show quantile probabilities as values
function(type, cuts, p) {
  n = length(cuts)
  p = paste(round(p * 100))
  cuts = paste(formatC(cuts[-n]), " - ", formatC(cuts[-1]))}

############################### Testing and Notes #############################


businesses_raw <- read_csv("community_data/ACC_Business_Tax_Division/business_tax_division_21.csv")

naics_22 <- read_csv("community_data/ACC_Business_Tax_Division/naics_22.csv")

businesses <- businesses_raw %>%
  select(USER_Customer__, USER_Full_Name, USER_DBA_Name, USER_NAICS_Description, 
         USER_NAICS_CODE, GEOID, SchoolID, School, X, Y) %>%
  rename("business_id" = USER_Customer__, "owner_name" = USER_Full_Name, 
         "business_name" = USER_DBA_Name, "naics_description" = USER_NAICS_Description,
         "naics_code" = USER_NAICS_CODE)

write_csv(businesses, "community_data/ACC_Business_Tax_Division/acc_business_clean2.csv")

business1 <- businesses %>%
  select(business_id, X, Y)

acc_business_clean <- read_csv("community_data/ACC_Business_Tax_Division/acc_business_clean.csv") 

bus2 <- acc_business_clean %>%
  left_join(business1) %>%
  select(-INTPTLAT,-INTPTLON) %>%
  rename("acc_naics" = naics_description) %>%
  left_join(naics_22, by = "naics_code")

write_csv(bus2, "community_data/ACC_Business_Tax_Division/business_tax_division_2021.csv")

########### MANUAL CLEANING OF NAICS_DESCRIPTION AND NAICS_CODE ###########

naics_22 <- X2_6_digit_2022_Codes %>%
  rename("naics_description" = NAICS_TITLE, "naics_code" = NAICS_CODE)

write_csv(naics_22, "community_data/ACC_Business_Tax_Division/naics_22.csv")

write_csv(acc_apprasial_data, "community_data/ACC_Parcels/acc_apprasial_clean")

grp_owners <- acc_parcels_data %>%
  group_by(OWNER_NAME) %>%
  summarise(parcels_owned = n(), area = sum(AREA))

grp_owners <- acc_apprasial_data %>%
  group_by(OWNER_NAME) %>%
  summarise(parcels_owned = n(), tot_val = sum(app_total), area = sum(land_area)) %>%
  mutate(psqft_val = round((tot_val/area), digits = 2), area = round(area, digits = 0))

parcel_owners <- grp_owners %>%
  summarise(cnt = n()) 

land_owners <- grp_owners %>%
  summarise(area = sum(AREA))

owners <- acc_apprasial_data %>%
  group_by(OWNER_NAME) %>%
  summarise(cnt = n()) %>%
  #summarise(area = sum(AREA))
  
  sales_per_year <- acc_sales_data %>%
  group_by(YEAR) %>%
  summarise(cnt = n())


vars<-load_variables(year=2020,dataset = "acs5") %>%
  filter(substr(name,1,7)=="B01001_")

write_csv(vars,"data/B01001.csv")


metadata<-read_csv("data/metadata_acsvars.csv")

acs_vars<-metadata$variable

df <- get_acs(geography = "tract", state = "GA",
              variable = acs_vars, year = 2020, geometry = TRUE)

meta <- read_csv("community_data/community_metadata.csv")

meta_type <- community_data %>%
  rename("variable" = var) %>%
  select(variable, type) %>%
  unique()

meta1 <- meta %>%
  right_join(meta_type) 

write_csv(meta1, "community_data/community_metadata.csv")

ACC_Apprasial_Values_2022 <- ACC_Apprasial_Values_2022 %>%
  select(REALKEY, PARCEL_NO, `2022 Total`, `2022 Land`, `2022 Imp`)

write_csv(ACC_Apprasial_Values_2022, "community_data/ACC_Parcels/ACC_apprasial_values_2022.csv")


  propsales_raw %>%
  filter(SALEPRICE > 1 & SALEPRICE < 1000) %>%
  ggplot(aes(x = SALEPRICE)) +
  geom_histogram()

## to dos 


### bussiness tax division data
### school data
### calculations for SchoolID 