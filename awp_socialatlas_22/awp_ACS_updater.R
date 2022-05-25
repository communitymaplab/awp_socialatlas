# If you have not already done so you must install a unique census api key 
# which you can obtain from [this page](https://api.census.gov/data/key_signup.html).

# census_api_key("YOUR KEY HERE", install = TRUE) 

source("awp_ACS_fetchdata.R")
  
awp_acs_updater(2020)