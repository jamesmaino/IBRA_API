library(sf)
library(tidyverse)
library(readxl) 
library(raster)

# evc <- st_read('data/EVC') %>% 
#   st_set_geometry(NULL)
# names(evc)
# write_csv(distinct(evc, EVC, X_EVCNAME), './data/EVC.csv')
# write_csv(distinct(evc, EVC_STUDY, X_EVCSTUDY), './data/EVC_STUDY.csv')

# xy = tibble(x=142.8, y=-37.217) %>%
#   st_as_sf(coords=c('x','y'), crs=4326) %>%
#   st_transform(st_crs(bioreg))

evc_cons <- read_xlsx('./data/Bioregional-Conservation-Status-for-each-BioEVC.xlsx') %>% 
  rename(EVC = 'EVC No.')
evc_rast <- raster('./data/EVC.tif')

bioreg <- st_read("data/VBIOREG100/VBIOREG100.shp")


# get IBRA code
sf_use_s2(FALSE)

shp <- st_read("data/IBRA7_regions/ibra7_regions.shp")

# load ibra description
ibra <- read_xlsx('./data/IBRA_2000_summary_report_5.1.xlsx') 

# load capad data
capad <- read_xlsx('./data/CAPAD2020/capad2020-terrestrial-national.xlsx', 
                  sheet='IBRA Bioregions', skip=1)  %>%
  mutate(REG_NAME_7 = `IBRA Region Name`  )


#* Get IBRA region and summary
#* @param lon The longitude
#* @param lat The latitude
#* @get /ibra
function(lon, lat) {
  out <- list()

  xy <- st_as_sf(tibble(x = lon, y = lat), coords = c("x", "y"), crs = 4326) %>%
    st_transform(st_crs(shp))

  ind <- which(st_intersects(shp, xy, sparse = FALSE))
  feat <- shp[ind, ] %>% 
    st_set_geometry(NULL) %>% 
    left_join(capad)
  
  out['IBRAName'] <- feat$REG_NAME_7 
  out['CAPADpercent'] <- feat$`% IBRA Region Protected`
  
  desc <- ibra %>% 
    filter(REG_CODE_7 == feat$REG_CODE_7) %>% 
    pull(DESCRIPTION)

  out['IBRADesc'] <- desc 

  b <- bioreg[xy, ] %>% 
    pull(BIOREGION)
  if(length(b) == 0) b <- NA

  e <- extract(evc_rast, xy)

  feat2 <- evc_cons %>% 
    filter(Bioregion == b) %>% 
    filter(EVC == e)
  if(nrow(feat2) == 0) feat2 <- feat2 %>% add_row()

  out['Bioregion'] <- feat2$Bioregion
  out['EVC'] <- feat2$`EVC Name`
  out['BCS'] <- feat2$BCS

  return(out)
}
