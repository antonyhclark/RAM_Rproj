# Load population data; read from csv if previously done (quicker) 
if (file.exists("data/df_pop.csv")) {
  df_pop <- read_csv("data/df_pop.csv")
} else {
  df_pop <- get_pop_data() %>% filter(year == year_of_interest,
                                      hscp2019name == hscp_of_interest)
  write_csv(df_pop, "data/df_pop.csv")
}

# add age groups
df_pop <- df_pop %>% 
  mutate(age_group=cut(age,
                       breaks = age_breaks,
                       labels = age_break_labels,
                       right = FALSE))

# Load urban-rural classification ref data
path_urban_rural <-
  paste0(
    "/conf/linkage/output/lookups/Unicode/Geography/Urban Rural Classification/",
    "datazone2011_urban_rural_2016.sav" 
  )
df_urban_rural <- read_sav(path_urban_rural) %>% clean_names()
path_urban_rural %>% remove()

# Join urban-rural data to pop data
df_pop <-
  df_pop %>% left_join(df_urban_rural %>% select(datazone2011, ur2_2016))

# pop by loc and age group
df_pop_age_group <- df_pop %>% 
  group_by(hscp_locality,age_group) %>% 
  summarise(pop=sum(pop)) %>% 
  ungroup()

# pop by loc and age group, simd1 DZs
df_pop_simd1 <- df_pop %>%
  filter(simd2020v2_hscp2019_quintile == 1) %>%
  group_by(hscp_locality, age_group) %>%
  summarise(pop_simd1 = sum(pop)) %>% 
  ungroup()

# pop by loc and age group, urban-dwelling
df_pop_urban <- df_pop %>%
  filter(ur2_2016 == 1) %>%
  group_by(hscp_locality, age_group) %>%
  summarise(pop_urban = sum(pop)) %>% 
  ungroup()

df_demographic <- Reduce(
  function(x, y) left_join(x, y),
  list(df_pop_age_group, df_pop_simd1, df_pop_urban)
)

df_demographic <- df_demographic %>% 
  adorn_totals(name=hscp_of_interest) %>% 
  mutate(prop_simd1=round(pop_simd1/pop,2),
         prop_urban=round(pop_urban/pop,2))

# check sums
check_totals <- sum(df_demographic$pop)/2 == sum(df_pop$pop)
check_simd1 <- sum(df_demographic$pop_simd1)/2 == 
  sum(df_pop[df_pop$simd2020v2_hscp2019_quintile==1,"pop"]) 
check_urban <- sum(df_demographic$pop_urban)/2 ==
  sum(df_pop[df_pop$ur2_2016==1,"pop"])

all_checks_demo <- all(check_totals,
                  check_simd1,
                  check_urban)
