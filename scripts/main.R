# Parameters ####
hscp_of_interest <- "South Lanarkshire" #used in all scripts
ages_of_interest <- 0:17 # used in u18_demo.R
year_of_interest <- 2019 # used in u18_demo.R
#age_grp_of_interest <- "0-17" # used in A_and_E.R
fin_year_of_interest <- "2019/20" # used in A_and_E.R
ltc_diagnosis_cut_off <- "2011-01-01" # used in LTC.R
#age_group_of_interest <- "<18" #used in Emergency_Admissions.R

# Load library and custom functions ####
source("scripts/library.R") # load required packages
source("scripts/misc_functions.R") # load helper functions

# Load and process data ####
source("scripts/u18_demo.R")
source("scripts/A_and_E.R")
source("scripts/Emergency_Admissions.R")
source("scripts/home_care.R")
source("scripts/LTC.R")

# Output dataframes to Excel ####
source("scripts/meta_data.R") # Named vector linking col names to plain english names
source("scripts/output.R")
