microbenchmark::microbenchmark({
  source("scripts/pop_0_17_SIMD_urban_rural.R")
  source("scripts/A_and_E.R")
  source("scripts/Emergency_Admissions.R")
  source("scripts/output.R")
},times = 1)

