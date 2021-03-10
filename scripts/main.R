
# Parameters
hscp_of_interest <- "South Lanarkshire"
ages_of_interest <- 0:17 # used in pop_0_17_SIMD_urban_rural.R
year_of_interest <- 2019 #

# Run all scripts
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
