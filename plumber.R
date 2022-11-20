library(sf)
library(tidyverse)
library(readxl) 

# get IBRA code
sf_use_s2(FALSE)

shp <- st_read("data/IBRA7_regions/ibra7_regions.shp")

# load ibra description
ibra <- read_xlsx('./data/IBRA_2000_summary_report_5.1.xlsx') 

#* Get IBRA region and summary
#* @param lon The longitude
#* @param lat The latitude
#* @get /ibra
function(lon, lat) {
  xy <- st_as_sf(tibble(x = lon, y = lat), coords = c("x", "y"), crs = 4326) %>%
    st_transform(st_crs(shp))

  ind <- which(st_intersects(shp, xy, sparse = FALSE))
  feat <- shp[ind, ] %>% 
    st_set_geometry(NULL)
  
  desc <- ibra %>% 
    filter(REG_CODE_7 == feat$REG_CODE_7) %>% 
    pull(DESCRIPTION)

  feat$desc <- desc 

  return(feat)
}
