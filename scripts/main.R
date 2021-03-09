microbenchmark::microbenchmark({
  hscp_of_interest <- "South Lanarkshire"
  source("scripts/library.R") # load required packages
  source("scripts/misc_functions.R") # load helper functions
  source("scripts/pop_0_17_SIMD_urban_rural.R")
  source("scripts/A_and_E.R")
  source("scripts/Emergency_Admissions.R")
  source("scripts/home_care.R")
  source("scripts/LTC.R")
  # Output dataframes to Excel
  source("scripts/meta_data.R") # Named vector linking col names to plain english names
  source("scripts/output.R")
  
},times = 1)
