library(magrittr)
library(dplyr)

# uncomment below if you need to install devtools
# usethis_source_url <- "https://cran.r-project.org/src/contrib/Archive/usethis/usethis_1.6.3.tar.gz"
# install.packages(usethis_source_url,repos = NULL,type="source")
# install.packages("devtools")

# https://github.com/antonyhclark/tc.utils
devtools::install_github("antonyhclark/tc.utils",
                         upgrade="never")
library(tc.utils)
hscp_of_interest <- "South Lanarkshire"
ages_of_interest <- 0:17
year_of_interest <- 2019

if (file.exists("data/df_pop.csv")) {
  df_pop <- readr::read_csv("data/df_pop.csv")
} else {
  df_pop <- get_pop_data() %>% filter(year == year_of_interest)
  readr::write_csv(df_pop, "data/df_pop.csv")
}

df_urban_rural <- haven::read_sav(
  "/conf/linkage/output/lookups/Unicode/Geography/Urban Rural Classification/datazone2011_urban_rural_2016.sav"
) %>% janitor::clean_names()

df_pop <-
  df_pop %>% left_join(df_urban_rural %>% select(datazone2011, ur2_2016))

df_pop_0_17 <- df_pop %>%
  filter(hscp2019name == hscp_of_interest,
         age %in% ages_of_interest) %>%
  group_by(hscp_locality) %>%
  summarise(pop_0_17 = sum(pop))

df_pop_0_17_simd_1 <- df_pop %>%
  filter(
    hscp2019name == hscp_of_interest,
    age %in% ages_of_interest,
    simd2020v2_sc_quintile == 1
  ) %>% # Scotland quintiles?
  group_by(hscp_locality) %>%
  summarise(pop_0_17_simd_1 = sum(pop))

df_pop_0_17_urban <- df_pop %>%
  filter(hscp2019name == hscp_of_interest,
         age %in% ages_of_interest) %>%
  group_by(ur2_2016, hscp_locality) %>%
  summarise(pop_0_17_urban = sum(pop), .groups = "drop") %>%
  tidyr::complete(ur2_2016, hscp_locality,
                  fill = list(pop_0_17_urban = 0)) %>%
  filter(ur2_2016 == 2) %>%
  select(-ur2_2016)

df_pop_0_17_summary <- Reduce(function(x, y, ...)
  merge(x, y, ...),
  list(df_pop_0_17, df_pop_0_17_simd_1, df_pop_0_17_urban)) %>%
  janitor::adorn_totals(name = hscp_of_interest)



df_pop_0_17_summary <- df_pop_0_17_summary %>%
  mutate(
    pop_0_17_simd_1_prop = round(pop_0_17_simd_1 / pop_0_17, 2),
    pop_0_17_urban_prop = round(pop_0_17_urban / pop_0_17, 2)
  )

remove(
  df_pop,
  df_pop_0_17,
  df_pop_0_17_simd_1,
  df_pop_0_17_urban,
  df_urban_rural,
  sheet_pop_0_17_summary
)
