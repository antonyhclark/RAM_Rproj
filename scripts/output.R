# List of lists with NULL placeholders for dataframes
output_list <- list(
  dem=list(label="Demographics",df=NULL,colour="blue"),
  ae=list(label="A and E",df=NULL,colour="red"),
  ea=list(label="Emergency Admissions",df=NULL,colour="orange"),
  ltc=list(label="LTCs",df=NULL,colour="yellow"),
  hc=list(label="Home Care",df=NULL,colour="purple")
)

# populate output list with dataframes
output_list$dem$df <- df_demographic
output_list$ae$df <- df_ae_summary
output_list$ea$df <- df_ea_summary
output_list$ltc$df <- df_ltc_summary
output_list$hc$df <- df_hc_summary_wide

# Write to output Excel workbook called: ####
# output_YYYY-MM-DD_HHMM.xlsx
output_file_path <- paste0("outputs/output_",
                           format(Sys.time(), format = '%Y-%m-%d_%H%M'),
                           ".xlsx")
# loop over the outputs, write one df per tab

for (list in output_list){
  
  write_df_to_worksheet(df=list$df,
                        wb_path = output_file_path,
                        ws_name = list$label,
                        tab_colour = list$colour)
}





# # Write demo tab to Excel output ####
# # Plain english column names obtained from named vector in meta_data.R script
# write_df_to_worksheet(df = df_demographic %>% setNames(.,nm=get_nice_colnames(colnames_dict,names(.))),
#                       wb_path = output_file_path,
#                       ws_name = "Demographics",
#                       tab_colour = "red")
# 
# # Write A&E data to Excel ####
# write_df_to_worksheet(df = df_ae_summary %>% setNames(.,nm=get_nice_colnames(colnames_dict,names(.))),
#                       wb_path = output_file_path,
#                       ws_name = "A and E",
#                       tab_colour = "grey")
# 
# # Write emergency admission data to Excel ####
# write_df_to_worksheet(df = df_ea_summary %>% setNames(.,nm=get_nice_colnames(colnames_dict,names(.))),
#                       wb_path = output_file_path,
#                       ws_name = "Emerg. Admissions",
#                       tab_colour = "yellow")
# 
# # Write home care data to Excel ####
# write_df_to_worksheet(df = df_hc_summary_wide %>% setNames(.,nm=get_nice_colnames(colnames_dict,names(.))),
#                       wb_path = output_file_path,
#                       ws_name = "Home Care",
#                       tab_colour = "blue")
# # Write home care by HSCP for discussion about unmatched patients
# # write_df_to_worksheet(df = df_hc_hours_by_hscp_of_res %>% setNames(.,nm=get_nice_colnames(colnames_dict,names(.))),
# #                       wb_path = output_file_path,
# #                       ws_name = "Home Care by HSCPofRes",
# #                       tab_colour = "steelblue2")
# 
# 
# # Write LTC data to Excel ####
# 
# write_df_to_worksheet(df = df_ltc_summary_wide %>% 
#                         setNames(.,nm=get_nice_colnames(colnames_dict,names(.))),
#                       wb_path = output_file_path,
#                       ws_name = "LTCs",
#                       tab_colour = "green")
