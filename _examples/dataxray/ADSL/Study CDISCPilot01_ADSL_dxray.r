pacman::p_load(rio, tidyverse)
# devtools::install_github("agstn/dataxray")
library(dataxray)

# IMPORT
adsl_orig <- import('2022-06-08/dat/adsl.xpt')

# RStudio IDE VIEWER
adsl_orig %>% 
   make_xray() %>% 
   view_xray() %>% 
   htmltools::save_html(file = "_examples/dataxray/ADSL/Study CDISCPilot01_ADSL_viewer.html")
   
# REPORT
report_xray(data = adsl_orig,
            data_name = 'ADSL',
            study = 'Study CDISCPilot01',
            loc = '_examples/dataxray/ADSL')