

# Load population data (get_pop_date reads from the stats lookup dir)
if (file.exists("data/df_pop.csv")) {
  df_pop <- readr::read_csv("data/df_pop.csv")
} else {
  df_pop <- tc.utils::get_pop_data() %>% filter(year == year_of_interest,
                                                hscp2019name == hscp_of_interest)
  readr::write_csv(df_pop, "data/df_pop.csv")
}

# Load urban-rural classification ref data
df_urban_rural <- haven::read_sav(
  "/conf/linkage/output/lookups/Unicode/Geography/Urban Rural Classification/datazone2011_urban_rural_2016.sav"
) %>% janitor::clean_names()

# Join urban-rural data to pop data
df_pop <-
  df_pop %>% left_join(df_urban_rural %>% select(datazone2011, ur2_2016))

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
    simd2020v2_sc_quintile == 1
  ) %>% # Scotland quintiles?
  group_by(hscp_locality) %>%
  summarise(pop_0_17_simd_1 = sum(pop))

# Urban population
df_pop_0_17_urban <- df_pop %>%
  filter(hscp2019name == hscp_of_interest,
         age %in% ages_of_interest) %>%
  group_by(ur2_2016, hscp_locality) %>%
  summarise(pop_0_17_urban = sum(pop), .groups = "drop") %>%
  tidyr::complete(ur2_2016, hscp_locality,
                  fill = list(pop_0_17_urban = 0)) %>%
  filter(ur2_2016 == 2) %>%
  select(-ur2_2016)

# Merge 4 dataframes (by Locality)
df_pop_0_17_summary <- Reduce(function(x, y, ...)
  merge(x, y, ...),
  list(df_pop_0_17, df_pop_0_17_simd_1, df_pop_0_17_urban)) %>%
  janitor::adorn_totals(name = hscp_of_interest)


# Add proportion columns
df_pop_0_17_summary <- df_pop_0_17_summary %>%
  mutate(
    pop_0_17_simd_1_prop = round(pop_0_17_simd_1 / pop_0_17, 2),
    pop_0_17_urban_prop = round(pop_0_17_urban / pop_0_17, 2)
  )

# Clean Global Environment
remove(
  df_pop_0_17,
  df_pop_0_17_simd_1,
  df_pop_0_17_urban,
  df_urban_rural
)
