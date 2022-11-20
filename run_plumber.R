library(plumber)
# 'plumber.R' is the location of the file shown above
root <- pr(paste0(getwd(), "/plumber.R"))
pr_run(root, host = "0.0.0.0", port = 8000)
