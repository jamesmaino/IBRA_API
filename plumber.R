library(sf)
library(tidyverse)
library(readxl) 
library(raster)

# evc <- st_read('data/EVC/NV2005_EXTENT/') %>% 
#   st_set_geometry(NULL)
# names(evc)
# write_csv(distinct(evc, EVC, X_EVCNAME), './data/EVC.csv')
# write_csv(distinct(evc, EVC_STUDY, X_EVCSTUDY), './data/EVC_STUDY.csv')

# xy = tibble(x=142.8, y=-37.217) %>%
#   st_as_sf(coords=c('x','y'), crs=4326) %>%
#   st_transform(st_crs(bioreg))


evc_bcs <- read_xlsx('./data/EVC/EVC_BCS_codes.xlsx') %>% 
  rename(EVC_BCS = Status_code)

evc <- read_csv('./data/EVC/evc_remaining_extent.csv') %>% 
  left_join(evc_bcs)

evc_rast <- raster('./data/EVC/EVC.tif')

bioreg <- st_read("data/VBIOREG100/VBIOREG100.shp")


# get IBRA code
sf_use_s2(FALSE)

shp <- st_read("data/IBRA/IBRA7_regions/ibra7_regions.shp")

# load ibra description
ibra <- read_xlsx('./data/IBRA/IBRA_2000_summary_report_5.1.xlsx') 

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
  
  out['IBRA_name'] <- feat$REG_NAME_7 
  out['CAPAD_IBRA_percent'] <- feat$`% IBRA Region Protected`
  
  desc <- ibra %>% 
    filter(REG_CODE_7 == feat$REG_CODE_7) %>% 
    pull(DESCRIPTION)

  out['IBRA_desc'] <- desc 

  b <- bioreg[xy, ] %>% 
    pull(BIOREGION)
  if(length(b) == 0) b <- NA

  e <- extract(evc_rast, xy)

  feat2 <- evc %>% 
    filter(BIOREGION == b) %>% 
    filter(EVC == e)
  if(nrow(feat2) == 0) feat2 <- feat2 %>% add_row()

  out['bioregion'] <- feat2$BIOREGION
  out['EVC'] <- feat2$X_EVCNAME
  out['BCS'] <- feat2$Status
  out['EVC_percent'] <- feat2$proportion_remaining * 100

  return(out)
}
