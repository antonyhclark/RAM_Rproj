# Load MSG data on Admissions
file_path_emergency_admissions <- 
  "/conf/LIST_analytics/MSG/2021-01 January/Breakdowns/1a-Admissions-breakdown.sav"
df_ea <- haven::read_sav(file_path_emergency_admissions) 

# Mutate date columns
df_ea_v2 <- df_ea %>% 
  janitor::clean_names() %>%
  mutate(month2=lubridate::parse_date_time(month,orders = "by"),.after=month) %>%
  mutate(fin_year=phsmethods::fin_year(month2),.after=month2) %>% 
  select(-c(month_num,year))
remove(df_ea)

# Filter for hscp_of_interest
df_ea_hscp_of_interest <- df_ea_v2 %>%
  filter(#age_groups == age_group_of_interest,
         council == hscp_of_interest,
         fin_year == fin_year_of_interest) %>%
  group_by(hscp_locality=locality) %>%
  summarise(emerg_admiss = sum(admissions)) %>% 
  janitor::clean_names()
remove(df_ea_v2)  

# Join EAs to pop data, compute rates
df_ea_summary <- df_ea_hscp_of_interest %>% 
  right_join(df_pop_sl_loc) %>% 
  janitor::adorn_totals(name = hscp_of_interest) %>% 
  mutate(ea_rate_1000 = round(emerg_admiss/pop*1000,2)) %>% 
  relocate(pop,.before=emerg_admiss)


