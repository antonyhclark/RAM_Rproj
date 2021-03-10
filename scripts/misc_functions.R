get_colours <- function(main_colour="grey"){
  indices <- grep(pattern=main_colour,x=colours())
  colour_options <- colours()[indices]
  return( colour_options )
}

n_row_pretty <- function(df){return(df %>% nrow() %>% formatC(.,big.mark = ","))}
# Helper functions to get total of LTCs for each individual
# get_max <- function(date_vector){return(max(date_vector,na.rm = T))}
# get_min <- function(date_vector){return(min(date_vector,na.rm = T))}

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
