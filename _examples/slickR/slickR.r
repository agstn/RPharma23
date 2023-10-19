# PACKAGES 
pacman::p_load(tidyverse, rio)
pacman::p_load(slickR)

# IMPORT
ww_c <- rio::import('img/ww_contributions.xlsx')

# slickR htmlwidgets
slickR(obj      = ww_c$Image, 
       objLinks = ww_c$Link,
       padding = 0,
       height = 725,
       width = "95%") %synch%
   ( slickR(ww_c$Title, slideType = 'p', height = 70, padding = 0) + settings(arrows = FALSE) ) %>% 
   htmlwidgets:::saveWidget(file = '_examples/slickR/slickR.html')