# Ref
# \\Freddy\DEPT\PHIBCS\PHI\Health & Social Care\Topics\Linkage\Reference Documents\File-layout-Individual-file.xlsx

# Get HSCP-Loc-DZ lookup file
lk_hscp_loc_dz11 <- get_HSCP_Loc_DZ11_lookup() %>% 
  select(hscp2019name,hscp2019,hscp_locality,datazone2011)

# Get hscp code from hscp name
hscp2019_of_interest <- lk_hscp_loc_dz11 %>% 
  select(hscp2019name,hscp2019) %>% 
  filter(hscp2019name==hscp_of_interest) %>% 
  unique() %>% 
  pull(hscp2019)



# Get Source Linkage Individual file for LTCs
path_source_individual <- 
  "/conf/hscdiip/01-Source-linkage-files/source-individual-file-202021.fst"
df_source_individual <- read.fst(path_source_individual)
remove(path_source_individual)

# This method of defining a variable for column selection works:
# cols_of_interest <- rlang::parse_expr("c(hscp2019,datazone2011,arth:digestive,arth_date:digestive_date)")
cols_of_interest <- parse_expr("c(hscp2019,datazone2011,arth:digestive)")
# Subset cols to reduce processing time
# !! is required so that dplyr knows how to use cols_of_interest
df_source_individual_v1 <- df_source_individual %>% select(!!cols_of_interest)

#df_source_individual_v1 %>% n_row_pretty()


# Filter for hscp, get total of LTCs, get earliest and latest LTC diagnosis
# Apply cuts to n_ltcs
# ?cut
# n-1 labels for n breaks
ltc_breaks <- c(
  "0" = 0, # [0,1) i.e. 0
  "1" = 1, # [1,2) i.e. 1
  "2" = 2, # [2,3) i.e. 2
  "3-7" = 3, # [3,8) i.e 3-7 inclusive
  ">7" = 8, # [8,infinity) i.e. 7 or more
  "NA" =  Inf 
)
ltc_break_labels <- names(ltc_breaks)[-length(ltc_breaks)]

# Filter for hscp of interest and calculate number of LTCs per patient
df_source_individual_v2 <- df_source_individual_v1 %>%
  filter(hscp2019==hscp2019_of_interest) %>% 
  mutate(n_ltc = rowSums( select(., arth:digestive) )) %>% 
  select(hscp2019,datazone2011,n_ltc)


# Bucket number of LTCs
df_source_individual_v2 <- df_source_individual_v2 %>%
  #filter(n_ltc > 0) %>% 
  # mutate(
  #   ltc_oldest = apply( select(., arth_date:digestive_date), 1, min, na.rm = T ),
  #   ltc_newest = apply( select(., arth_date:digestive_date), 1, max, na.rm = T )
  # ) %>% 
  mutate(n_ltc_factor=cut(n_ltc,
                          breaks = ltc_breaks,
                          labels = names(ltc_breaks)[-length(ltc_breaks)],
                          right = FALSE # closed interval on left [lower,upper)
                          )) 

# Join HSCP, Locality
df_source_individual_v2 <- df_source_individual_v2 %>% 
  left_join(
    lk_hscp_loc_dz11 %>% 
      filter(hscp2019==hscp2019_of_interest) %>% 
      select(hscp_locality,datazone2011)
  ) %>% 
  select(hscp_locality,datazone2011,n_ltc,n_ltc_factor)

df_ltc_summary <- df_source_individual_v2 %>% 
  #filter(ltc_oldest>ltc_diagnosis_cut_off) %>% 
  count(hscp_locality,n_ltc_factor) %>% 
  pivot_wider(names_from = n_ltc_factor,
              names_prefix = "n LTC: ",
              values_from = n) %>% 
  clean_names() %>% 
  adorn_totals(name = hscp_of_interest)
