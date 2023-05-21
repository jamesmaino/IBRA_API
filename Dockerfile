FROM rstudio/plumber

WORKDIR /home

ENV VERSION 1
ADD . /home

EXPOSE 8080
# library(sf)
# library(tidyverse)
# library(readxl) 
# library(raster)
# library(rgdal)

RUN R -e "install.packages(c('sf','tidyverse','readxl','rgdal','raster'),dependencies=TRUE, repos='http://cran.rstudio.com/')"

ENTRYPOINT ["Rscript", "run_plumber.R"]