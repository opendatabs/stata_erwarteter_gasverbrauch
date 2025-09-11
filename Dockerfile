FROM rocker/rstudio:4.5.1
#FROM rocker/r-base
## Using a base image with R4.2.1 and RSTUDIO_VERSION=2022.07.2+576
WORKDIR /code

RUN apt-get update && apt-get install -y \
    sudo \
    gdebi-core \
    libcairo2-dev \
    libxt-dev \
    libcurl4 \
    libcurl4-openssl-dev \
    libssl-dev \
    r-cran-rstan \
    libxml2-dev \
    default-jdk \
    libglpk-dev


## Explicitly setting my default RStudio Package Manager Repo
## Uses packages as at 07/03/2024
RUN echo "r <- getOption('repos'); \
	  r['CRAN'] <- 'https://packagemanager.rstudio.com/cran/__linux__/focal/2024-03-07'; \
	  options(repos = r);" > ~/.Rprofile

RUN Rscript -e "install.packages(c('httr', 'data.table', 'dplyr', 'lubridate', 'knitr', 'highcharter', 'DT', 'caret', 'tibble', 'rsample', 'jtools'), dependencies = TRUE)"

COPY . /code/

CMD ["Rscript", "Gasverbrauch_OGD.R"]
