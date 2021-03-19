# Ref docs:
# https://www.isdscotland.org/Health-Topics/Health-and-Social-Community-Care/Health-and-Social-Care-Integration/Dataset/_docs/Source-SC2-Data-Specification-v1-0.pdf

# https://www.isdscotland.org/Health-Topics/Health-and-Social-Community-Care/Health-and-Social-Care-Integration/docs/Revised-Source-Dataset-Definitions-and-Recording-Guidance-June-2018.pdf

# follows, to some extent, syntax of 
# /conf/LIST_analytics/Lanarkshire/Projects/Social Care/
# Home Care/Syntax/1 - SOUTH demographics 2020-06-05.sps

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

# Get HSCP-Loc-DZ lookup file
lk_hscp_loc_dz11 <- get_HSCP_Loc_DZ11_lookup() %>% 
  select(hscp2019name,hscp_locality,datazone2011)

# Get home care demographic data from IR
path_hc_demo <- 
  paste0('/conf/LIST_analytics/Lanarkshire/Projects/Social Care/Home Care/Data/',
         'IR2020-00096 South Lanarkshire demographics.zsav')


df_demo <- haven::read_sav(path_hc_demo) %>% 
  clean_names() %>% 
  # subset columns for convenience
  select(social_care_id, chi=seeded_chi_number,
         dob = chi_date_of_birth,
         datazone2011=chi_datazone,
         gender=chi_gender_description, simd_sct_quintile) %>% 
  # Join hscp2019name,hscp_locality
  left_join(lk_hscp_loc_dz11) %>% 
  # Bring geography columns to left for convenience
  relocate(hscp2019name, hscp_locality, datazone2011,.before=social_care_id) %>% 
  # Sort
  arrange(hscp2019name, hscp_locality, datazone2011,social_care_id)
#df_demo %>% View()
# Read home care hours ####
path_hc_demo %>% remove()
path_hc <- 
  paste0(
    "/conf/LIST_analytics/Lanarkshire/Projects/Social Care/Home Care/Data/",
    "IR2020-00096 South Lanarkshire Homecare.zsav"  
  )
df_hc <- haven::read_sav(path_hc) %>% clean_names()
path_hc %>% remove() #clean env

# where age is NA, replace with chi age
df_hc$age[is.na(df_hc$age)] <- df_hc$chi_age[is.na(df_hc$age)]

# df_hc$period %>% unique() %>% sort()
# df_hc$financial_year %>% unique() %>% sort()

# Join geography columns by social care id
df_hc_demo <- df_hc %>% 
  left_join(df_demo,by="social_care_id") %>% 
  select(-sending_location) %>% # drop sending location; it's always the same
  rename(provider_code=hc_service_provider) %>% 
  left_join(lk_provider) %>% 
  relocate(provider_description, .after=provider_code)
#(df_hc_demo$hc_hours %>% sum()) == total_hc_hours_raw
# Add age group
df_hc_demo <- df_hc_demo %>% 
  mutate(age_group=cut(age,
                       breaks = age_breaks,
                       labels = age_break_labels,
                       right = FALSE))

# add level for unknown age
levels(df_hc_demo$age_group) <- c(levels(df_hc_demo$age_group),"unknown")
# assign new level to records with unknown age
df_hc_demo$age_group[is.na(df_hc_demo$age_group)] <- "unknown"
# Visually check age_groups
df_hc_demo %>% 
  arrange(age) %>% 
  group_by(age_group) %>% 
  summarise(age_1st=first(age),
            age_Lst=last(age),
            n=n())
#(df_hc_demo$hc_hours %>% sum()) == total_hc_hours_raw

df_hc_summary <- full_join(
  x= df_hc_demo %>% 
    filter(hscp2019name==hscp_of_interest) %>% 
    group_by(hscp_locality,age_group,provider_description,.drop=FALSE) %>% 
    summarise(hc_hours=sum(hc_hours)),
  y= df_pop %>% 
    group_by(hscp_locality,age_group,.drop=FALSE) %>% 
    summarise(pop=sum(pop)) 
) %>% 
  mutate(hc_rate=round(hc_hours/pop*1000,1))


if (sum(df_hc_summary[df_hc_summary$age_group=="unknown","hc_hours"])==0){
  df_hc_summary <- df_hc_summary %>% filter(age_group != "unknown")
}

# divide by 5 to account for the 5 repeats of pop on lhs
sum(df_hc_summary$pop,na.rm = T)/5==sum(df_pop$pop)
sum(df_hc_summary$hc_hours) == sum(df_hc_demo[df_hc_demo$hscp2019name==hscp_of_interest,
                                          "hc_hours"],na.rm = T)

df_hc_summary_wide <- df_hc_summary %>% 
  ungroup() %>% 
  select(-hc_rate) %>% 
  pivot_wider(names_from = provider_description,
              values_from = hc_hours) %>% 
  mutate(total_hc_hours:=rowSums(select(.,c(`LA/HSCP/NHS Board`:`Third Sector`)))) %>% 
  adorn_totals(name=hscp_of_interest)

if ( sum(df_hc_summary_wide$Other) == 0 ) {
  df_hc_summary_wide <- df_hc_summary_wide %>% select(-Other)
}

df_hc_summary_wide %>% 
  mutate(hours_per_head_per_year=round(total_hc_hours/pop,1))


