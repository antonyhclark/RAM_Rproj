file_path_homecare <- 
  "/conf/LIST_analytics/Lanarkshire/Projects/Social Care/Home Care/Data/IR2020-00096 South Lanarkshire Homecare.zsav"

df_homecare <- haven::read_sav(file_path_homecare) %>% janitor::clean_names()

