# https://cran.r-project.org/web/packages/openxlsx/openxlsx.pdf
library(openxlsx) # prefer this to xlsx as no java dependency

# Write to output Excel workbook called: ####
# output_YYYY-MM-DD_HHMM.xlsx
output_file_path <- paste0("outputs/output_",
                           format(Sys.time(), format = '%Y-%m-%d_%H%M'),
                           ".xlsx")

# Create empty workbook object and cell styles ####
wb_output <- openxlsx::createWorkbook()

# Write worksheet for child pop inc simd and urban rural splits ####
colour_child_demo <- "steelblue2"
ws_child_demo <- openxlsx::addWorksheet(
  wb=wb_output,
  sheetName = "Pop 0-17 demographics",
  gridLines = F,
  tabColour = colour_demo,
  zoom = 90
)

setColWidths(wb_output,
             ws_child_demo, 
             1:ncol(df_pop_0_17_summary_out), 
             widths = floor(300/ncol(df_pop_0_17_summary_out)))

writeData(
  wb=wb_output,
  sheet=ws_child_demo,
  x=df_pop_0_17_summary_out,
  headerStyle = cs_col_headers,
  name = deparse(quote(df_pop_0_17_summary_out))
)

saveWorkbook(wb_output, output_file_path)

remove(wb_output, sheet_pop_0_17_summary)


# New worksheet for home care ####
wb_output <- openxlsx::loadWorkbook(output_file_path)
ws_homecare <- addWorksheet(wb = wb_output,
                            sheetName = "Home Care",
                            gridLines = F,
                            tabColour = "yellow",
                            zoom = 90)

writeData(wb = wb_output,
          sheet = ws_homecare,
          x = df_hc_summary,
          headerStyle = cs_col_headers)

addStyle(wb_output,
         ws_homecare,
         rows = 1,cols = 1:ncol(df_hc_summary),
         style = createStyle(fgFill = "yellow"),
         stack = T)

setColWidths(wb_output,
             ws_homecare, 
             1:ncol(df_hc_summary), 
             widths = 20)


saveWorkbook(wb_output, output_file_path,overwrite = T)



