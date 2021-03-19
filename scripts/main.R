start_time <- Sys.time()
# small function for printing messages to console
cat_paste0 <- function(...) cat(paste0(...))

# Parameters ####
hscp_of_interest <- "South Lanarkshire" #used in all scripts
ages_of_interest <- 0:17 # used in u18_demo.R
year_of_interest <- 2019 # used in u18_demo.R
#age_grp_of_interest <- "0-17" # used in A_and_E.R
fin_year_of_interest <- "2019/20" # used in A_and_E.R
#ltc_diagnosis_cut_off <- "2011-01-01" # used in LTC.R
#age_group_of_interest <- "<18" #used in Emergency_Admissions.R
age_breaks <- c(
  "0-17" = 0,
  "18-64" = 18,
  "65 plus" = 65,
  "NA" = Inf
)
age_break_labels <- names(age_breaks)[-length(age_breaks)]

list_of_scripts <- c(
  # packages and functions
  "library.R",
  "misc_functions.R",
  # data load and wrangling
  "pop_aggregations.R",
  "A_and_E.R",
  "Emergency_Admissions.R",
  "home_care.R",
  "LTC.R",
  # Output to Excel
  "meta_data.R",
  "output.R"
)

broken_script <- NULL
try_result <- NULL
for (script in list_of_scripts) {
  script_path <- paste0("scripts/", script)
  try_result <- try( suppressMessages( source(script_path,echo = F) ) )
  try_errored <- class(try_result) == "try-error"
  
  if (try_errored) {
    broken_script <- script
    break
  } else {
    cat_paste0("The script ",script," has executed without error:\t\t",
               format(round(Sys.time()-start_time,1)),
               "\n")
  }
  
}

if (!is.null(broken_script)){
  cat_paste0(
    "main.R has been aborted\n",
    "There is an error in: ", broken_script, "\n",
    try_result)
} else {
  end_time <- Sys.time()
  execution_time <- format(round(end_time-start_time,1))
  cat_paste0(
      "All outputs produced without error\n",
      "Total execution time:\n",
      execution_time,"\n"
  )  
}