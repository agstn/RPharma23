pacman::p_load(rio, tidyverse) 
# devtools::install_github("agstn/dataxray")
library(dataxray)

# IMPORT
adlb_orig <- import('2022-06-08/dat/adlbh.xpt')

# SUBSET
adlb <- adlb_orig %>% 
   filter( !str_detect(PARAMCD, '_') ) %>% 
   select(USUBJID,  
          PARAM, AVISIT, AVISITN, ADY, AVAL) %>% 
   mutate(AVISIT = str_trim(AVISIT)) 

# RStudio IDE VIEWER
adlb %>% 
   make_xray(by = c('PARAM')) %>% 
   view_xray(by = c('PARAM')) %>% 
   htmltools::save_html(file = "_examples/dataxray/ADLB/Study CDISCPilot01_ADLB_viewer.html")

# REPORT
report_xray(data = adlb,
            data_name = 'ADLB',
            by = c('PARAM'),
            study = 'Study CDISCPilot01',
            loc = '_examples/dataxray/ADLB')
