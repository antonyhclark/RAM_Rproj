devtools::install_github("Public-Health-Scotland/phsmethods",
                         upgrade = "never")

# Parameters ####
age_grp_of_interest <- "0-17"
hscp_of_interest <- "South Lanarkshire"
# fin_years_of_interest <- c("2017/18","2018/19","2019/20") # could use average over three years?
fin_year_of_interest <- "2019/20"

# MSG data ####
file_path_AE_breakdowns <- 
  "/conf/LIST_analytics/MSG/2021-01 January/Breakdowns/3-A&E Breakdowns.sav"
df_AE_breakdowns <- haven::read_sav(file_path_AE_breakdowns) %>% 
  janitor::clean_names() %>% 
  mutate(month2=lubridate::parse_date_time(month,orders = "b-Y"),.after=month) %>% 
  mutate(fin_year=phsmethods::fin_year(month2),.after=month2) %>% 
  select(-c(cal_year,month_num,month,month2))

# Wrangle data for HSCP of interest ####
df_AE_hscp_of_interest <- df_AE_breakdowns %>%
  filter(age_grp == age_grp_of_interest,
         council == hscp_of_interest,
         #fin_year %in% fin_year_of_interest,
         fin_year == fin_year_of_interest) %>%
  group_by(hscp_locality=locality) %>%
  summarise(ae_attendances = sum(attendances)) %>% 
# %>% 
#   tidyr::pivot_wider(names_prefix="ae_",
#                      names_from = fin_year,
#                      values_from = ae_attendances) %>% 
  janitor::clean_names() %>% 
  janitor::adorn_totals(name = hscp_of_interest)

# Join attendances to pop data, compute rates
df_pop_0_17_summary_v2 <- df_pop_0_17_summary %>% 
  left_join(df_AE_hscp_of_interest) %>% 
  mutate(ae_rate_1000 = round(ae_attendances/pop_0_17*1000,2))
remove(df_pop_0_17_summary)
