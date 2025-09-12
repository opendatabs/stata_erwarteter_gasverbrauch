library(knitr)
library(data.table)
library(httr)

if (file.exists("OL_Gasverbrauch.R")) {
  #Delete file if it exists
  file.remove("OL_Gasverbrauch.R")
}

knitr::purl("OL_Gasverbrauch.Rmd", output = "OL_Gasverbrauch.R")

original_script <- readLines("OL_Gasverbrauch.R")

modified_script <- gsub("100353_gasverbrauch.csv", "data/export/100353_gasverbrauch.csv", original_script, fixed=TRUE)

writeLines(modified_script, "OL_Gasverbrauch.R")

source("OL_Gasverbrauch.R")
