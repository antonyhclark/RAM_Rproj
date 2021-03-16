# Load the MSG indicators spreadsheet for reconciliation purposes
df_msg_ea_for_rec <-
  read.xlsx(
    xlsxFile = "/conf/LIST_analytics/MSG/2021-01 January/Integration-performance-indicators-v1.38.xlsx",
    sheet = "1",
    rows = c(8:42),
    cols = c(1:45)
  ) %>%
  clean_names() %>%
  filter(partnership_of_residence == hscp_of_interest) %>%
  pivot_longer(cols = c(2:45),
               names_to = "month",
               values_to = "emerg_admiss") %>%
  mutate(month = parse_date_time(month, orders = "by")) %>%
  mutate(fy = fin_year(month)) %>%
  filter(fy == fin_year_of_interest)
  

# Load MSG data on Admissions
file_path_emergency_admissions <- 
  "/conf/LIST_analytics/MSG/2021-01 January/Breakdowns/1a-Admissions-breakdown.sav"
df_ea <- read_sav(file_path_emergency_admissions) %>% clean_names()

# Mutate date columns into a date data type
df_ea_v2 <- df_ea %>% 
  mutate(month2=parse_date_time(month,orders = "by"),.after=month) %>%
  mutate(fin_year=fin_year(month2),.after=month2) %>% 
  select(-c(month_num,year))
remove(df_ea)

# Filter for hscp_of_interest
df_ea_hscp_of_interest <- df_ea_v2 %>%
  filter(#age_groups == age_group_of_interest,
         council == hscp_of_interest,
         fin_year == fin_year_of_interest) %>%
  group_by(hscp_locality=locality) %>%
  summarise(emerg_admiss = sum(admissions)) %>% 
  clean_names()
remove(df_ea_v2)  

sum(df_ea_hscp_of_interest$emerg_admiss) == sum(df_msg_ea_for_rec$emerg_admiss)


# Join EAs to pop data, compute rates
df_ea_summary <- df_ea_hscp_of_interest %>% 
  right_join(df_pop_loc) %>% 
  adorn_totals(name = hscp_of_interest) %>% 
  mutate(ea_rate_1000 = round(emerg_admiss/pop*1000,2)) %>% 
  relocate(pop,.before=emerg_admiss)
sum(df_ea_summary$emerg_admiss[1:4])==sum(df_msg_ea_for_rec$emerg_admiss)

