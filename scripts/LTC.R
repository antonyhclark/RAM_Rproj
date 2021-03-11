# Ref
# \\Freddy\DEPT\PHIBCS\PHI\Health & Social Care\Topics\Linkage\Reference Documents\File-layout-Individual-file.xlsx

# Get HSCP-Loc-DZ lookup file
lk_hscp_loc_dz11 <- tc.utils::get_HSCP_Loc_DZ11_lookup() %>% 
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
df_source_individual <- fst::read.fst(path_source_individual)
remove(path_source_individual)
# df_source_individual$datazone2011
# df_source_individual$hscp2019
# This works:
cols_of_interest <- rlang::parse_expr("c(hscp2019,datazone2011,arth:digestive,arth_date:digestive_date)")
# Subset cols to reduce processing time
df_source_individual_v1 <- df_source_individual %>% select(!!cols_of_interest)
#df_source_individual_v1 %>% n_row_pretty()


# Filter for hscp, get total of LTCs, get earliest and latest LTC diagnosis
# Apply cuts to n_ltcs

df_source_individual_v2 <- df_source_individual_v1 %>%
  filter(hscp2019==hscp2019_of_interest) %>% 
  mutate(n_ltc = rowSums( select(., arth:digestive) )) %>%
  filter(n_ltc > 0) %>% 
  mutate(
    ltc_oldest = apply( select(., arth_date:digestive_date), 1, min, na.rm = T ),
    ltc_newest = apply( select(., arth_date:digestive_date), 1, max, na.rm = T )
  ) %>% 
  mutate(n_ltc_factor=cut(n_ltc,c(0,1,2,5,10,Inf),c("1","2","3-5","6-10",">10"))) %>% 
  left_join(
    lk_hscp_loc_dz11 %>% 
      filter(hscp2019==hscp2019_of_interest) %>% 
      select(hscp_locality,datazone2011)
  ) %>% 
  relocate(hscp2019,hscp_locality,datazone2011,n_ltc,n_ltc_factor,ltc_oldest,ltc_newest)

#df_source_individual_v2 %>% n_row_pretty()
#df_source_individual_v2$n_ltc %>% max()
df_ltc_summary <- df_source_individual_v2 %>% 
  filter(ltc_oldest>ltc_diagnosis_cut_off) %>% 
  count(hscp_locality,n_ltc_factor) %>% 
  pivot_wider(names_from = n_ltc_factor,
              names_prefix = "n LTC: ",
              values_from = n) %>% 
  janitor::clean_names() %>% 
  janitor::adorn_totals(name = hscp_of_interest)
