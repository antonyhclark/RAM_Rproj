# Filter pop data for ages of interest and hscp of interest
df_pop_0_17 <- df_pop %>%
  filter(hscp2019name == hscp_of_interest,
         age %in% ages_of_interest) %>%
  group_by(hscp_locality) %>%
  summarise(pop_0_17 = sum(pop))

# Filter pop data for ages of interest and hscp of interest
# only population in SIMD 1 (most deprived)
df_pop_0_17_simd_1 <- df_pop %>%
  filter(
    hscp2019name == hscp_of_interest,
    age %in% ages_of_interest,
    simd2020v2_hscp2019_quintile == 1
  ) %>% # Scotland quintiles?
  group_by(hscp_locality) %>%
  summarise(pop_0_17_simd_1 = sum(pop))

# Urban population
df_pop_0_17_urban <- df_pop %>%
  filter(hscp2019name == hscp_of_interest,
         age %in% ages_of_interest) %>%
  group_by(ur2_2016, hscp_locality) %>%
  summarise(pop_0_17_urban = sum(pop), .groups = "drop") %>%
  complete(ur2_2016, hscp_locality,
                  fill = list(pop_0_17_urban = 0)) %>%
  filter(ur2_2016 == 1) %>%
  select(-ur2_2016)

# Merge 4 dataframes (by Locality)
df_pop_0_17_summary <- Reduce(function(x, y, ...)
  merge(x, y, ...),
  list(df_pop_0_17, df_pop_0_17_simd_1, df_pop_0_17_urban)) %>%
  janitor::adorn_totals(name = hscp_of_interest) #add totals before computing rates


# Add proportion columns
df_pop_0_17_summary <- df_pop_0_17_summary %>%
  mutate(
    pop_0_17_simd_1_prop = round(pop_0_17_simd_1 / pop_0_17, 2),
    pop_0_17_urban_prop = round(pop_0_17_urban / pop_0_17, 2)
  )
View(df_pop_0_17_summary)
# Clean Global Environment
remove(
  df_pop_0_17,
  df_pop_0_17_simd_1,
  df_pop_0_17_urban,
  df_urban_rural
)
