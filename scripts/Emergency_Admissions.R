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
path_ea <- 
  "/conf/LIST_analytics/MSG/2021-01 January/Breakdowns/1a-Admissions-breakdown.sav"
df_ea <- read_sav(path_ea) %>% clean_names()
path_ea %>% remove()
df_ea <- df_ea %>% mutate(age_group=as.factor(age_groups))
df_ea %>% select(contains("age"))


# Recode age groups ####
old_levels <- levels(df_ea$age_group)
n_levels <- length(old_levels)
vec_00_17 <- old_levels[1]
vec_18_64 <- old_levels[3:11]
vec_65plus <- old_levels[c(12:n_levels,2)]
n_levels == length(c(vec_00_17,vec_18_64,vec_65plus))

levels(df_ea$age_group) <-
  list("0-17" = vec_00_17,
       "18-64" = vec_18_64,
       "65 plus" = vec_65plus)
df_ea %>% select(contains("age"))

# Visually check recoding
df_ea %>% 
  group_by(age_group) %>%
  summarise(age_groups_1st=first(age_groups),
            age_groups_Lst=last(age_groups))

# Mutate date columns into a date data type
df_ea_v2 <- df_ea %>% 
  mutate(month2=parse_date_time(month,orders = "%b%y"),.after=month) %>%
  mutate(fin_year=fin_year(month2),.after=month2) %>% 
  select(-c(month_num,year))
#remove(df_ea)

# Filter for hscp_of_interest
df_ea_hscp_of_interest <- df_ea_v2 %>%
  filter(#age_groups == age_group_of_interest,
         council == hscp_of_interest,
         fin_year == fin_year_of_interest) %>%
  group_by(hscp_locality=locality,
           age_group) %>%
  summarise(emerg_admiss = sum(admissions)) %>% 
  clean_names()
remove(df_ea_v2)  

sum(df_ea_hscp_of_interest$emerg_admiss) == sum(df_msg_ea_for_rec$emerg_admiss)


# Join EAs to pop data, compute rates
# df_ea_summary <- df_ea_hscp_of_interest %>% 
#   right_join(df_pop_loc) %>% 
#   adorn_totals(name = hscp_of_interest) %>% 
#   mutate(ea_rate_1000 = round(emerg_admiss/pop*1000,1)) %>% 
#   relocate(pop,.before=emerg_admiss)
# sum(df_ea_summary$emerg_admiss[1:4])==sum(df_msg_ea_for_rec$emerg_admiss)

df_ea_summary <- right_join(
  x = df_ea_hscp_of_interest,
  y = df_pop %>%
    group_by(hscp_locality, age_group) %>%
    summarise(pop = sum(pop))
) %>% 
  adorn_totals(name = hscp_of_interest) %>% 
  mutate(ea_rate_1000 = round(emerg_admiss/pop*1000,1))

# check sum remembering to remove the hscp total from consideration on lhs
sum(df_ea_summary$emerg_admiss[-nrow(df_ea_summary)])==sum(df_msg_ea_for_rec$emerg_admiss)






