library(openxlsx)

# Script to define cell styles etc.

# Column headers
cs_col_headers <- createStyle(
  fontName = "Calibri",
  fontSize = 10,
  fontColour = "black", # obtained from browsing colours()
  numFmt = "GENERAL",
  border = c("top", "bottom"),
  borderColour = c("darkslategrey","black"),
  borderStyle = c("thin","medium"),
  bgFill = NULL,
  fgFill = c("lightslategrey"),
  halign = "center",
  valign = "center",
  textDecoration = c("bold"),
  wrapText = T,
  textRotation = NULL,
  # indent = 2,
  locked = NULL,
  hidden = NULL
)

