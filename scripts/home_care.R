# Ref doc:
# https://www.isdscotland.org/Health-Topics/Health-and-Social-Community-Care/Health-and-Social-Care-Integration/Dataset/_docs/Source-SC2-Data-Specification-v1-0.pdf

# https://www.isdscotland.org/Health-Topics/Health-and-Social-Community-Care/Health-and-Social-Care-Integration/docs/Revised-Source-Dataset-Definitions-and-Recording-Guidance-June-2018.pdf

if (!all(c("tc.utils", "dplyr", "magrittr") %in% (.packages()))){source("scripts/library.R")}

# follow syntax of 
# /conf/LIST_analytics/Lanarkshire/Projects/Social Care/
# Home Care/Syntax/1 - SOUTH demographics 2020-06-05.sps

# 'GET FILE' # Demographics ####
# This file links social care id to chi and geography (inc dz)
df_demo <- haven::read_sav(
  '/conf/LIST_analytics/Lanarkshire/Projects/Social Care/Home Care/Data/IR2020-00096 South Lanarkshire demographics.zsav'
)
df_demo <- df_demo %>% mutate(age=tc.utils::get_age_from_dob(chi_date_of_birth))

# Checks ####
# Check that there is one row per social care id in the demographics file
# (df_demo %>% nrow()) == (df_demo %>% select(social_care_id) %>% unique() %>% nrow())
# (df_demo %>% nrow()) == (df_demo %>% unique() %>% nrow())

# write df to csv for inspection in Excel
# readr::write_csv(df_demo,"~/fav/RAM_Rproj/data/df_sou_lan_demo.csv")
# \\stats\LIST_analytics\Lanarkshire\Projects\Resource%20Allocation%20Model\RAM_Rproj\data\

# Take a subset of columns and give better names for convenience
df_demo_v2 <- df_demo %>% 
  select(social_care_id, chi=seeded_chi_number, datazone2011=chi_datazone, age, gender=chi_gender_description, simd_sct_quintile)

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
  select(-sending_location) %>% 
  rename(provider_code=hc_service_provider) %>% 
  left_join(lk_provider) %>% 
  relocate(provider_description, .after=provider_code)


# df_hc_v2$hc_service_provider
# check that user exists in demo file
# df_hc_v2 %>% 
#   mutate(matched_in_demo=!is.na(datazone2011)) %>% 
#   janitor::tabyl(matched_in_demo)

# df_hc_v2 %>% count(period) # why the big jump in records between Q2 and Q3?

df_hc_summary <- df_hc_v2 %>% 
  group_by(hscp2019name,hscp_locality,provider_description) %>% 
  summarise(hc_hours=sum(hc_hours)) %>% 
  tidyr::pivot_wider(names_from=provider_description,
                     names_prefix = "provider_",
                     values_from=hc_hours) %>% 
  filter(hscp2019name==hscp_of_interest) %>% 
  janitor::clean_names() %>% 
  tidyr::replace_na(list(provider_other_local_authority=0)) %>% 
  janitor::adorn_totals(name = hscp_of_interest)






