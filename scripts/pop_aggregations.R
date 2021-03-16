# Load population data (get_pop_date reads from the stats lookup dir)
# read from local csv if this has alredy been done once (quicker)
if (file.exists("data/df_pop.csv")) {
  df_pop <- read_csv("data/df_pop.csv")
} else {
  df_pop <- get_pop_data() %>% filter(year == year_of_interest,
                                      hscp2019name == hscp_of_interest)
  write_csv(df_pop, "data/df_pop.csv")
}

# Load urban-rural classification ref data
path_urban_rural <-
  "/conf/linkage/output/lookups/Unicode/Geography/Urban Rural Classification/datazone2011_urban_rural_2016.sav"
df_urban_rural <- read_sav(path_urban_rural) %>%
  clean_names()

# Join urban-rural data to pop data
df_pop <-
  df_pop %>% left_join(df_urban_rural %>% select(datazone2011, ur2_2016))

# Aggregate population by locality
df_pop_loc <- df_pop %>%
  filter(hscp2019name == hscp_of_interest) %>%
  group_by(hscp_locality) %>%
  summarise(pop = sum(pop))
