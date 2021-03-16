# simple function to see range of colours available in R given a 'main colour'
# e.g. shades of grey
get_colours <- function(main_colour="grey"){
  indices <- grep(pattern=main_colour,x=colours())
  colour_options <- colours()[indices]
  return( colour_options )
}

# Same as nrow but adds comma separators for 1000s etc.
n_row_pretty <- function(df){return(df %>% nrow() %>% formatC(.,big.mark = ","))}

# function leveraging openxlsx to write df to a spreadsheet tab
write_df_to_worksheet <- function(df,wb_path,ws_name,tab_colour="white"){
  # Header style
  cs_col_headers <- openxlsx::createStyle(
    fontName = "Calibri", fontSize = 10, fontColour = "black",
    numFmt = "GENERAL", border = c("top", "bottom"),
    borderColour = c("darkslategrey", "black"),
    borderStyle = c("thin", "medium"),
    fgFill = c("lightslategrey"),
    halign = "center", valign = "center",
    textDecoration = c("bold"), wrapText = T
  )
  
  if (!file.exists(wb_path)){
    wb_obj <- openxlsx::createWorkbook()
  } else {
    wb_obj <- openxlsx::loadWorkbook(wb_path)
  }
  ws_obj <- openxlsx::addWorksheet(
    wb=wb_obj, sheetName = ws_name,
    gridLines = F, tabColour = tab_colour, zoom = 90
  )
  
  setColWidths(wb_obj, ws_obj, 1:ncol(df), 
               widths = floor(255/ncol(df)))
  
  writeData(wb_obj, ws_obj, x=df,
    headerStyle = cs_col_headers
    #name = eval(deparse(enexpr(df)))
  )
  saveWorkbook(wb_obj, wb_path, overwrite = T)
}

check_packages <- function(required_packages=NULL){
  if (is.null(required_packages)){
    cat("\nOnly standard PHS packages are required.")
    return(T)
  } else if (!is.null(required_packages)){
    cat("\nOne or ")
  }
}

# copied from tc.utils ####
# https://github.com/antonyhclark/tc.utils

get_HSCP_Loc_DZ11_lookup <- function(file_path = "/conf/linkage/output/lookups/Unicode/Geography/HSCP Locality/HSCP Localities_DZ11_Lookup_20200825.rds") {
  readRDS(file_path) %>% tidyr::as_tibble()
}

# does as you might expect :-)
get_age_from_dob <- function(dob,
                             age_day = today(),
                             units = "years",
                             floor = TRUE) {
  age = interval(dob, age_day) / duration(num = 1, units = units)
  if (floor)
    return(as.integer(floor(age)))
  return(age)
}

# copied from phsmethods::
# https://github.com/Public-Health-Scotland/phsmethods/blob/master/R/fin_year.R

fin_year <- function(date) {
  
  if (!inherits(date, c("Date", "POSIXct"))) {
    stop("The input must have Date or POSIXct class")
  }
  
  # Simply converting all elements of the input vector resulted in poor
  # performance for large vectors. The function was rewritten to extract
  # a vector of unique elements from the input, convert those to financial year
  # and then match them back on to the original input. This vastly improves
  # performance for large inputs.
  
  x <- tibble::tibble(dates = unique(date)) %>%
    dplyr::mutate(fyear = paste0(ifelse(lubridate::month(.data$dates) >= 4,
                                        lubridate::year(.data$dates),
                                        lubridate::year(.data$dates) - 1),
                                 "/",
                                 substr(
                                   ifelse(lubridate::month(.data$dates) >= 4,
                                          lubridate::year(.data$dates) + 1,
                                          lubridate::year(.data$dates)),
                                   3, 4)),
                  fyear = ifelse(is.na(.data$dates),
                                 NA_character_,
                                 .data$fyear))
  
  tibble::tibble(dates = date) %>%
    dplyr::left_join(x, by = "dates") %>%
    dplyr::pull(.data$fyear)
  
}
