# PACKAGES
pacman::p_load(rio, tidyverse)
pacman::p_load(labelled)
pacman::p_load(trelliscopejs, plotly)

# IMPORT
adlb_orig <- import('2022-06-08/dat/adlbh.xpt')

# SUBSET
adlb <- adlb_orig %>% 
   select(USUBJID, TRTP, AGE, RACE, SEX,
          PARAM, PARAMCD, PARCAT1,
          AVISIT, AVISITN, ADY, AVAL) %>% 
   mutate(AVISIT = str_trim(AVISIT)) %>% 
   filter(PARAMCD %in% c('BASO','EOS','HCT','HGB','LYM','MCH','MCHC','MCV','MONO','PLAT','RBC','WBC')) %>% 
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
      panely = list(panel %>% ggplotly() %>% config(displayModeBar = F))) 

# COG + TRELLISCOPE
adlb_gg %>%
   mutate(min = min(data$AVAL) %>% round(2),
          max = max(data$AVAL) %>% round(2),
          sd   = sd(data$AVAL) %>% round(2)) %>% 
   select(-data, -panel, -ends_with(c('_min','_max'))) %>% 
   ungroup() %>% 
   trelliscope(
      name = "ADLB trelliscope example",
      panel_col = 'panely',
      path = '_examples/trelliscopejs/trelliscope_adlb',
      state = list(sort = list(sort_spec('USUBJID', dir = 'desc'))),
      nrow = 1,
      ncol = 3,
      height = 300,
      width = 600,
      self_contained = FALSE,
      thumb = FALSE,
      auto_cog = FALSE)
