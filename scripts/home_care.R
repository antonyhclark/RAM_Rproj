# Ref docs:
# https://www.isdscotland.org/Health-Topics/Health-and-Social-Community-Care/Health-and-Social-Care-Integration/Dataset/_docs/Source-SC2-Data-Specification-v1-0.pdf

# https://www.isdscotland.org/Health-Topics/Health-and-Social-Community-Care/Health-and-Social-Care-Integration/docs/Revised-Source-Dataset-Definitions-and-Recording-Guidance-June-2018.pdf

# follow syntax of 
# /conf/LIST_analytics/Lanarkshire/Projects/Social Care/
# Home Care/Syntax/1 - SOUTH demographics 2020-06-05.sps

# Get home care data from IR
df_demo <- haven::read_sav(
  '/conf/LIST_analytics/Lanarkshire/Projects/Social Care/Home Care/Data/IR2020-00096 South Lanarkshire demographics.zsav'
)
df_demo <- df_demo %>% mutate(age=get_age_from_dob(chi_date_of_birth))

# Take a subset of columns and give better names for convenience
df_demo_v2 <- df_demo %>% 
  select(social_care_id, chi=seeded_chi_number, 
         datazone2011=chi_datazone, age, 
         gender=chi_gender_description, simd_sct_quintile)

# Get HSCP-Loc-DZ lookup file
lk_hscp_loc_dz11 <- tc.utils::get_HSCP_Loc_DZ11_lookup() %>% 
  select(hscp2019name,hscp_locality,datazone2011)

# Join HSCP, Locality (by dz)
df_demo_v3 <- df_demo_v2 %>% 
  left_join(lk_hscp_loc_dz11) %>% 
  relocate(hscp2019name, hscp_locality, datazone2011,.before=social_care_id) %>% 
  arrange(hscp2019name, hscp_locality, datazone2011,social_care_id)

# Get home care hours by quarter-user (user identified by social care id)
df_hc <- haven::read_sav(
  "/conf/LIST_analytics/Lanarkshire/Projects/Social Care/Home Care/Data/IR2020-00096 South Lanarkshire Homecare.zsav"
)

# https://devhints.io/datetime # Good resource for date-time codes

# Write home care hours data to csv for inspection in Excel
# readr::write_csv(df_hc,paste0("~/fav/RAM_Rproj/data/df_hc_",
#                               format(Sys.time(),format = "%Y-%m-%d_%H%M"),
#                               ".csv"))

# hc_service_provider ####
# https://www.isdscotland.org/Health-Topics/Health-and-Social-Community-Care/Health-and-Social-Care-Integration/docs/Revised-Source-Dataset-Definitions-and-Recording-Guidance-June-2018.pdf
# See 4.3 HOME CARE SERVICE PROVIDER

# create small lookup dataframe
lk_provider <- data.frame(
  provider_code = as.character(c(1:5)),
  provider_description = c(
    "LA/HSCP/NHS Board",
    "Private",
    "Other Local Authority",
    "Third Sector",
    "Other"
  )
)

# Join geography columns by social care id
# df_demo_v3$social_care_id
# df_hc$social_care_id
df_hc_v2 <- df_hc %>% 
  left_join(df_demo_v3,by="social_care_id") %>% 
  select(-sending_location) %>% # drop sending location; it's always the same
  rename(provider_code=hc_service_provider) %>% 
  left_join(lk_provider) 

# %>% relocate(provider_description, .after=provider_code) # function not available in dplyr 0.8.x


# df_hc_v2$hc_service_provider
# check that user exists in demo file
# df_hc_v2 %>% 
#   mutate(matched_in_demo=!is.na(datazone2011)) %>% 
#   janitor::tabyl(matched_in_demo)

# df_hc_v2 %>% count(period) # why the big jump in records between Q2 and Q3?

df_hc_summary <- df_hc_v2 %>% 
  filter(hscp2019name==hscp_of_interest) %>% 
  group_by(hscp_locality,provider_description) %>% 
  summarise(hc_hours=sum(hc_hours)) %>% 
  pivot_wider(names_from=provider_description,
                     names_prefix = "provider_",
                     values_from=hc_hours) %>% 
  
  clean_names() %>% 
  replace_na(list(provider_other_local_authority=0)) %>% 
  adorn_totals(name = "total_all_providers", where="col") %>% 
  left_join(df_pop_loc) %>% 
  adorn_totals(name = hscp_of_interest) %>% 
  mutate(rate_per_1000=total_all_providers/pop*1000)


# Checks ####
# Check that there is one row per social care id in the demographics file
# (df_demo %>% nrow()) == (df_demo %>% select(social_care_id) %>% unique() %>% nrow())
# (df_demo %>% nrow()) == (df_demo %>% unique() %>% nrow())

# write df to csv for inspection in Excel
# readr::write_csv(df_demo,"~/fav/RAM_Rproj/data/df_sou_lan_demo.csv")
# \\stats\LIST_analytics\Lanarkshire\Projects\Resource%20Allocation%20Model\RAM_Rproj\data\



