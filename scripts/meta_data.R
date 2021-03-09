# Rename columns for output ####
colnames_dict <- c(
  "hscp2019name" = "HSCP",
  "hscp_locality" ="Locality",
  "pop_0_17" ="Populations aged 0-17",
  "pop_0_17_simd_1" ="Populations aged 0-17 in most deprived quintile",
  "pop_0_17_urban" ="Populations aged 0-17 living in an urban area",
  "pop_0_17_simd_1_prop" ="Populations aged 0-17 in most deprived quintile (proportion)",
  "pop_0_17_urban_prop" ="Populations aged 0-17 living in an urban area (proportion)",
  "ae_attendances" = "Number of A&E attendances",
  "ae_rate_1000" = "A&E attendance rate per 1000 population",
  "emerg_admiss" = "Emergency admissions 0-17",
  "ea_rate_1000" = "Emergency admissions rate 0-17",
  "provider_la_hscp_nhs_board" = "Provider: LA/HSCP/NHS Board",
  "provider_private"="Provider: Private", 
  "provider_third_sector" = "Provider: Third Sector", 
  "provider_other_local_authority" = "Provider: Other LA"
)

ltcs <- 
  data.frame(
    stringsAsFactors = FALSE,
    ltc = c("arth","asthma","atrialfib",
           "cancer","cvd","liver","copd","dementia","diabetes",
           "epilepsy","chd","hefailure","ms","parkinsons",
           "refailure","congen","bloodbfo","endomet","digestive"),
    
    
    ltc_desc = c("Arthritis Artherosis","Asthma","Atrial Fibrillation",
           "Cancer ",
           "Cerebrovascular Disease (CVD)","Chronic Liver Disease",
           "Chronic Obstructive Pulmonary Disease (COPD)",
           "Dementia ","Diabetes",
           "Epilepsy ","Coronary heart disease (CHD)",
           "Heart Failure ","Multiple Sclerosis",
           "Parkinsons","Renal Failure",
           "Congenital Problems",
           "Diseases of Blood and Blood Forming Organs",
           "Other Endocrine Metabolic Diseases","Other diseases of Digestive system")
  )
