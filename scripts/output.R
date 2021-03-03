# https://cran.r-project.org/web/packages/xlsx/xlsx.pdf
library(xlsx)


# Rename columns for output ####
colnames_dict <- c(
  "hscp_locality" ="Locality",
  "pop_0_17" ="Populations aged 0-17",
  "pop_0_17_simd_1" ="Populations aged 0-17 in most deprived quintile",
  "pop_0_17_urban" ="Populations aged 0-17 living in an urban area",
  "pop_0_17_simd_1_prop" ="Populations aged 0-17 in most deprived quintile (proportion)",
  "pop_0_17_urban_prop" ="Populations aged 0-17 living in an urban area (proportion)",
  "ae_attendances" = "Number of A&E attendances",
  "ae_rate_1000" = "A&E attendance rate per 1000 population",
  "emerg_admiss" = "Emergency admissions 0-17",
  "ea_rate_1000" = "Emergency admissions rate 0-17"
)
df_pop_0_17_summary_out <- df_pop_0_17_summary_v3
names(df_pop_0_17_summary_out) <- df_pop_0_17_summary_v3 %>% 
  names() %>% 
  tc.utils::get_nice_colnames(.,colnames_dict)

# Write to Excel, set up ####
# Italic style
wb <- createWorkbook()
cs_rows <- CellStyle(wb) +
  Font(wb, isItalic = TRUE) 
# Blue text
cs_blue <- CellStyle(wb) +
  Font(wb, color = "blue", heightInPoints = 9)
# Column headers
cs_cols <- CellStyle(wb) +
  Font(wb,  heightInPoints = 9, isBold = TRUE) +
  Border() +
  Alignment(wrapText = T)

sheet_pop_0_17_summary <-
  createSheet(wb, sheetName = "pop_0_17_summary")

setColumnWidth(sheet_pop_0_17_summary, 1:ncol(df_pop_0_17_summary_v3), colWidth=20)

addDataFrame(
  df_pop_0_17_summary_out,
  sheet_pop_0_17_summary,
  colnamesStyle = cs_cols,
  colStyle = list(`1` = cs_blue),
  row.names = F
)
output_file_path <- paste0("outputs/output_",
                           format(Sys.time(), format = '%Y-%m-%d_%H%M'),
                           ".xlsx")
saveWorkbook(wb, output_file_path)

remove(
  wb,
  sheet_pop_0_17_summary,
  colnames_dict
  )
