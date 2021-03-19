# Ref
# \\Freddy\DEPT\PHIBCS\PHI\Health & Social Care\Topics\Linkage\Reference Documents\File-layout-Individual-file.xlsx

# Get HSCP-Loc-DZ lookup file
lk_hscp_loc_dz11 <- get_HSCP_Loc_DZ11_lookup() %>% 
  select(hscp2019name,hscp2019,hscp_locality,datazone2011)

# Get hscp code from hscp name
hscp2019_of_interest <- lk_hscp_loc_dz11[lk_hscp_loc_dz11$hscp2019name==hscp_of_interest,]$hscp2019[1]

# Get Source Linkage Individual file for LTCs
path_source_individual <- 
  "/conf/hscdiip/01-Source-linkage-files/source-individual-file-201920.fst"
df_source_individual <- read.fst(path_source_individual)
remove(path_source_individual)

# Add age_group col
df_source_individual <- df_source_individual %>%
  mutate(age_group = cut(
    age,
    breaks = age_breaks,
    labels = age_break_labels,
    right = FALSE
  ))

# Visually inspect age_groups vs. first/last age in group
df_source_individual %>% arrange(age) %>%
  group_by(age_group) %>%
  summarise(age_1st = first(age),
            age_lst = last(age),
            n=n())

# Define buckets for n LTCs
# n-1 labels for n breaks
# ltc_breaks <- c(
#   "0" = 0, # [0,1) i.e. 0
#   "1" = 1, # [1,2) i.e. 1
#   "2" = 2, # [2,3) i.e. 2
#   "3-7" = 3, # [3,8) i.e 3-7 inclusive
#   ">7" = 8, # [8,infinity) i.e. 7 or more
#   "NA" =  Inf 
# )
# ltc_break_labels <- names(ltc_breaks)[-length(ltc_breaks)]

ltc_breaks <- c(
  "0" = 0, # [0,1) i.e. 0
  "1" = 1, # [1,2) i.e. 1
  "2" = 2, # [2,3) i.e. 2
  "3-5" = 3, # [3,8) i.e 3-7 inclusive
  ">5" = 6, # [8,infinity) i.e. 7 or more
  "NA" =  Inf 
)
ltc_break_labels <- names(ltc_breaks)[-length(ltc_breaks)]

# Filter for hscp of interest and calculate number of LTCs per patient
df_source_individual_v2 <- df_source_individual %>%
  # Subset cols to reduce processing time
  select(c(hscp2019, age_group, datazone2011, arth:digestive)) %>%
  # filter for hscp of interest
  filter(hscp2019 == hscp2019_of_interest) %>%
  # the LTC flags are 0/1 - sum to get total number of LTCs
  mutate(n_ltc = rowSums(select(., arth:digestive))) %>%
  # subset cols again (dropping the LTC flag cols)
  select(hscp2019, age_group, datazone2011, n_ltc) %>%
  # Bucket number of LTCs
  mutate(n_ltc_factor = cut(
    n_ltc,
    breaks = ltc_breaks,
    labels = ltc_break_labels,
    right = FALSE # closed interval on left [lower,upper)
  )) %>%
  # Join HSCP, Locality
  left_join(
    lk_hscp_loc_dz11 %>%
      filter(hscp2019 == hscp2019_of_interest) %>%
      select(hscp_locality, datazone2011)
  ) %>%
  select(hscp_locality, age_group, n_ltc, n_ltc_factor)

# Visually check the ltc buckets
df_source_individual_v2 %>% 
  arrange(n_ltc) %>% 
  group_by(n_ltc_factor) %>% 
  summarise(n_ltc_1st=first(n_ltc),
            n_ltc_Lst=last(n_ltc))


# df_ltc_summary <- df_source_individual_v2 %>% 
#   #filter(ltc_oldest>ltc_diagnosis_cut_off) %>% 
#   count(hscp_locality,age_group,n_ltc_factor) %>% 
#   pivot_wider(names_from = n_ltc_factor,
#               names_prefix = "n LTC: ",
#               values_from = n) %>% 
#   clean_names() %>% 
#   adorn_totals(name = hscp_of_interest)

df_ltc_summary <- full_join(
  x=df_source_individual_v2 %>% 
    group_by(hscp_locality,age_group,n_ltc_factor,.drop=FALSE) %>% 
    summarise(n=n())
    ,
  y=df_pop %>% 
    group_by(hscp_locality,age_group,.drop=FALSE) %>% 
    summarise(pop=sum(pop))
) %>% ungroup %>% 
  mutate(rate=round(n/pop*1000,1))

df_ltc_summary_wide <- df_ltc_summary %>% 
  pivot_wider(names_from = n_ltc_factor,
              names_prefix = "n_ltc_",
              values_from = n,
              id_cols = c(hscp_locality, age_group, pop)) %>% 
  clean_names()

at_least_1_ltc <- df_ltc_summary_wide %>% 
  select(n_ltc_1:n_ltc_5) %>% 
  rowSums() %>% 
  data.frame(at_least_1_ltc=.)

df_ltc_summary_wide <- bind_cols(df_ltc_summary_wide, at_least_1_ltc)
(df_ltc_summary_wide %>% select(n_ltc_1:n_ltc_5) %>% sum()) == sum(df_ltc_summary_wide$at_least_1_ltc)

df_ltc_summary_wide <- df_ltc_summary_wide %>%
  mutate(`At least 1 LTC rate per 1000` = round(at_least_1_ltc / pop * 1000, 1))

