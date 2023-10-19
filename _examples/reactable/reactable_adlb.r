# PACKAGES
pacman::p_load(rio, tidyverse)
pacman::p_load(labelled)
pacman::p_load(reactable, reactablefmtr, plotly)

# IMPORT
adlb_orig <- import('2022-06-08/dat/adlbh.xpt')

# SUBSET
adlb <- adlb_orig %>% 
   select(USUBJID, TRTP, AGE, RACE, SEX,
          PARAM, PARAMCD, PARCAT1,
          AVISIT, AVISITN, ADY, AVAL) %>% 
   mutate(AVISIT = str_trim(AVISIT)) %>% 
   filter(PARAMCD %in% c('BASO','EOS','HCT','HGB')) %>% #'LYM','MCH','MCHC','MCV','MONO','PLAT','RBC','WBC' )) %>% 
   filter(USUBJID %in% sample(.$USUBJID, 20) )

# RANGE
adlb_r <- adlb %>% 
   drop_na(ADY, AVAL) %>% 
   group_by(PARAMCD) %>% 
   summarise(across(c(ADY, AVAL), list(min = min, max = max)))

# NEST
adlb_nest <- adlb %>% 
   nest_by(USUBJID, TRTP, AGE, RACE, SEX, PARAM, PARAMCD, PARCAT1) %>% 
   filter(nrow(data) > 10) %>% 
   filter( !str_detect(PARAMCD, '_') ) %>% 
   right_join(adlb_r)

# GGPLOT
adlb_gg <- adlb_nest %>% 
   mutate(
      panel = list(
         ggplot(data = data,
                aes(y = AVAL, x = ADY, label = AVISIT, label2 = AVISITN ) ) +
            geom_point() +
            geom_line() +
            scale_x_continuous(name = 'Analysis Relative Day',
                               breaks = data$ADY %>% unique(),
                               labels = data$ADY %>% unique(),
                               limits = c(ADY_min, ADY_max)) +
            scale_y_continuous(name = PARAM,
                               limits = c(AVAL_min, AVAL_max)) +
            theme_bw() +
            theme( panel.grid.minor = element_blank() ) ),
      panely = list(panel %>% ggplotly(width = 500, height = 250) %>% config(displayModeBar = F))) 

adlb_gg %>% 
   ungroup() %>% 
   select(USUBJID, TRTP, AGE, RACE, SEX, PARCAT1, PARAM, panely) %>% 
   reactable(.,
             bordered = TRUE,
             highlight = TRUE,
             searchable = TRUE,
             filterable = TRUE,
             pagination = FALSE,
             height = 650,
             theme = fivethirtyeight(),
             defaultColDef = colDef( vAlign = 'center',
                                     width = 125),
             columns = list(
                TRTP = colDef(
                   width = 200
                ),
                PARAM = colDef(
                   width = 325
                ),
                panely = colDef( 
                   name = 'FIG',
                   width = 75,
                   filterable = FALSE,
                   cell = function(value){
                      if (length(value)>1) htmltools::tags$button("")
                   },
                   details = function(index) {
                      .$panely[[index]]
                   }
                )
             )
   ) %>% 
   reactablefmtr::google_font(font_family = "Ubuntu Mono") %>% 
   save_reactable_test("_examples/reactable/reactable_adlb.html")

