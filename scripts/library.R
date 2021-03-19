require(magrittr)
library(dplyr)
library(tidyr)
library(readr)
library(janitor)
library(haven)
library(fst)
library(lubridate)
library(tibble)
library(openxlsx)
#library(rlang)

# Network location of PHS-wide libraries:
# /opt/R/3.6.1/lib64/R/library


#install.packages("fst")

# uncomment below if you need to install devtools
# usethis_source_url <- "https://cran.r-project.org/src/contrib/Archive/usethis/usethis_1.6.3.tar.gz"
# install.packages(usethis_source_url,repos = NULL,type="source")
# install.packages("devtools")

# https://github.com/antonyhclark/tc.utils
# https://github.com/Public-Health-Scotland/phsmethods
# devtools::install_github("antonyhclark/tc.utils", upgrade = "never")
# devtools::install_github("Public-Health-Scotland/phsmethods", upgrade = "never")

# library(tc.utils)