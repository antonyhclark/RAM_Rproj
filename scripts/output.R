# https://cran.r-project.org/web/packages/openxlsx/openxlsx.pdf
library(openxlsx) # prefer this to xlsx as no java dependency

# Write to output Excel workbook called: ####
# output_YYYY-MM-DD_HHMM.xlsx
output_file_path <- paste0("outputs/output_",
                           format(Sys.time(), format = '%Y-%m-%d_%H%M'),
                           ".xlsx")

# Write demo tab to Excel output ####
# Plain english column names obtained from named vector in meta_data.R script
write_df_to_worksheet(df = df_pop_0_17_summary %>% setNames(.,nm=get_nice_colnames(colnames_dict,names(.))),
                      wb_path = output_file_path,
                      ws_name = "Children Demographics",
                      tab_colour = "red")

# Write A&E data to Excel ####

# Write emergency admission data to Excel ####


# Write home care data to Excel ####
write_df_to_worksheet(df = df_hc_summary %>% setNames(.,nm=get_nice_colnames(colnames_dict,names(.))),
                      wb_path = output_file_path,
                      ws_name = "Home Care",
                      tab_colour = "blue")

df_pop_0_17_summary %>% setNames(.,nm=get_nice_colnames(colnames_dict,names(.)))

get_nice_colnames(colnames_dict,names(df_pop_0_17_summary))




