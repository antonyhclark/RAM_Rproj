get_colours <- function(main_colour="grey"){
  indices <- grep(pattern=main_colour,x=colours())
  colour_options <- colours()[indices]
  return( colour_options )
}


write_df_to_worksheet <- function(df,workbook,worksheet,tabcolour="white"){
  cs_col_headers <- openxlsx::createStyle(
    fontName = "Calibri",
    fontSize = 10,
    fontColour = "black",
    numFmt = "GENERAL",
    border = c("top", "bottom"),
    borderColour = c("darkslategrey", "black"),
    borderStyle = c("thin", "medium"),
    fgFill = c("lightslategrey"),
    halign = "center",
    valign = "center",
    textDecoration = c("bold"),
    wrapText = T
  )
  
  if (!file.exists(workbook)){
    wb <- openxlsx::createWorkbook()
  } else {
    wb <- openxlsx::loadWorkbook(workbook)
  }
  ws <- openxlsx::addWorksheet(
    wb=wb,
    sheetName = worksheet,
    gridLines = F,
    tabColour = tabcolour,
    zoom = 90
  )
  
  setColWidths(wb,
               ws, 
               1:ncol(df), 
               widths = floor(300/ncol(df)))
  writeData(
    wb=wb_obj,
    ws,
    x=df,
    headerStyle = cs_col_headers,
    name = deparse(quote(df))
  )
  
  saveWorkbook(wb_obj, wb_path)
  
}