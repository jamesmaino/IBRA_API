library(readxl)
library(tidyverse)

# export attribute tables using QGIS load in tables here
d1 <- read_xlsx('NV1750.xlsx')
d2 <- read_xlsx('NV2005.xlsx')
names(d1)

d1sum <- d1 %>% 
  group_by(BIOREGION, EVC, X_EVCNAME, EVC_BCS) %>% 
  summarise(area1750_ha = sum(HECTARES)) 
d2sum <- d2 %>% 
  group_by(BIOREGION, EVC, X_EVCNAME, EVC_BCS) %>% 
  summarise(area2005_ha = sum(HECTARES)) 

d = d1sum %>%
    left_join(d2sum) %>% 
    mutate(proportion_remaining = area2005_ha/area1750_ha) %>% 
    arrange((proportion_remaining))

write_csv(d, './evc_remaining_extent.csv')
