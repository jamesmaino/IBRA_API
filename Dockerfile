FROM rstudio/plumber

WORKDIR /home

ENV VERSION 1
ADD . /home

EXPOSE 8080

ENTRYPOINT ["Rscript", "run_plumber.R"]