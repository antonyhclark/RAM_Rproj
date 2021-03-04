df_hscp_loc_dz11 <- tc.utils::get_HSCP_Loc_DZ11_lookup()
hscp2019_of_interest <- df_hscp_loc_dz11 %>% 
  select(hscp2019name,hscp2019) %>% 
  unique() %>% 
  filter(hscp2019name==hscp_of_interest) %>% 
  pull(hscp2019)

path <- tc.utils::add_quotes(tc.utils::win_to_lin(readline(prompt="Enter path: ")) )
cat(path)

readline(prompt="Enter path: ")file_path_homecare <- 
  "/conf/LIST_analytics/Lanarkshire/Projects/Social Care/Home Care/Data/IR2020-00096 South Lanarkshire Homecare.zsav"

df_homecare <- haven::read_sav(file_path_homecare) %>% janitor::clean_names()
df_homecare %>% colnames()
df_homecare %>% View()
df_homecare %>% group_by(hc_service_provider) %>% summarise(hc_hours=sum(hc_hours))


df_hc_pop_sou_lan <- haven::read_sav("/conf/LIST_analytics/Lanarkshire/Projects/Social Care/Home Care/Lookups/HCPop_South.sav")

lk_chi_scid <- haven::read_sav("/conf/LIST_analytics/Lanarkshire/Projects/Social Care/Home Care/Lookups/SocialCare_ID_Lookup.sav") %>% 
  janitor::clean_names()

lk_anon_chi <- fst::read.fst("/conf/hscdiip/01-Source-linkage-files/Anon-to-CHI-lookup.fst")
df_source_individual <- fst::read.fst("/conf/hscdiip/01-Source-linkage-files/source-individual-file-201920.fst")
df_source_individual %>% colnames()
df_source_
names(df_source_individual)[names(df_source_individual) %>% order()]
names(df_source_individual) %>% grep(pattern = "demo")

df_source_episode <- fst::read.fst("/conf/hscdiip/01-Source-linkage-files/source-episode-file-202021.fst")
df_source_episode %>% View()
df_se_names <- data.frame(names(df_source_episode))
df_se_names %>% arrange()
df_source_episode %>% select(location)

df_source_episode %>% filter(hscp2019==hscp2019_of_interest) %>% group_by(locality) %>% summarise(hc_hours=sum(hc_hours,na.rm = T))
df_source_episode$hc_hours

df_hc_extract <- haven::read_sav(
  "/conf/hscdiip/Social Care Extracts/SPSS extracts/201718_Client_extract_fix.zsav"
)
df_hc_extract %>% colnames()
