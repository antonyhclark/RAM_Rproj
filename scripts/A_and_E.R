# Load MSG data ####
path_AE_breakdowns <- 
  "/conf/LIST_analytics/MSG/2021-01 January/Breakdowns/3-A&E Breakdowns.sav"
df_AE_breakdowns <- haven::read_sav(path_AE_breakdowns) %>% clean_names()
path_AE_breakdowns %>% remove()

# Reformat data and age group columns to make them easier to work with
df_AE_breakdowns <- df_AE_breakdowns %>%
  mutate(age_group=factor(age_grp)) %>% 
  mutate(month2=lubridate::parse_date_time(month,orders = "b-Y"),.after=month) %>% 
  mutate(fin_year=fin_year(month2),.after=month2) %>% 
  select(-c(cal_year,month_num,month,month2))

# Recode levels of age group ####
old_levels <- levels(df_AE_breakdowns$age_group)
n_levels <- length(old_levels)
vec_00_17 <- old_levels[2]
vec_18_16 <- old_levels[3:(n_levels-8)]
vec_65plus <- old_levels[(n_levels-7):n_levels]
levels(df_AE_breakdowns$age_group) <- 
  list("unknown" = "",
       "0-17" = vec_00_17,
       "18-64" = vec_18_16,
       "65 plus" = vec_65plus)

# check new levels are set correctly by visual inspection
df_AE_breakdowns %>% 
  select(age_grp,age_group) %>% 
  group_by(age_group) %>% 
  summarise(age_grp_1st=first(age_grp),
            age_grp_Lst=last(age_grp))


# Wrangle data for HSCP of interest ####
df_AE_hscp_of_interest <- df_AE_breakdowns %>%
  filter(council == hscp_of_interest,
         fin_year == fin_year_of_interest) %>%
  group_by(hscp_locality=locality,
           age_group) %>%
  summarise(ae_attendances = sum(attendances)) %>% 
  clean_names()
  
# Join attendances to pop data, compute rates
# df_ae_summary <- df_AE_hscp_of_interest %>% 
#   right_join(df_pop_loc) %>% 
#   adorn_totals(name = hscp_of_interest) %>% 
#   mutate(ae_rate_1000 = round(ae_attendances/pop*1000,2)) 
# %>% relocate(pop,.before=ae_attendances)

df_ae_summary <- right_join(
  x= df_pop %>% 
    group_by(hscp_locality,age_group) %>% 
    summarise(pop=sum(pop)),
  y= df_AE_hscp_of_interest
) %>% 
  adorn_totals(name = hscp_of_interest) %>% 
  mutate(ae_rate_1000 = round(ae_attendances/pop*1000,1))

# Check sums (the '2' divisor accounts for the total row)
check_pop <- sum(df_ae_summary$pop)/2 == sum(df_pop$pop)
check_att <- sum(df_ae_summary$ae_attendances)/2 == 
  sum(df_AE_breakdowns[df_AE_breakdowns$fin_year=="2019/20" & df_AE_breakdowns$council==hscp_of_interest,
                       "attendances"])
all_checks_ae <- all(check_pop,check_att)
