########################################################
#        Renku install section                         #

FROM renku/renkulab-r:4.3.1-0.25.0 as builder

ARG RENKU_VERSION=2.9.4

# Install renku from pypi or from github if a dev version
RUN if [ -n "$RENKU_VERSION" ] ; then \
        source .renku/venv/bin/activate ; \
        currentversion=$(renku --version) ; \
        if [ "$RENKU_VERSION" != "$currentversion" ] ; then \
            pip uninstall renku -y ; \
            gitversion=$(echo "$RENKU_VERSION" | sed -n "s/^[[:digit:]]\+\.[[:digit:]]\+\.[[:digit:]]\+\(rc[[:digit:]]\+\)*\(\.dev[[:digit:]]\+\)*\(+g\([a-f0-9]\+\)\)*\(+dirty\)*$/\4/p") ; \
            if [ -n "$gitversion" ] ; then \
                pip install --no-cache-dir --force "git+https://github.com/SwissDataScienceCenter/renku-python.git@$gitversion" ;\
            else \
                pip install --no-cache-dir --force renku==${RENKU_VERSION} ;\
            fi \
        fi \
    fi

#             End Renku install section                #
########################################################
FROM renku/renkulab-r:4.3.1-0.25.0

ARG DEBIAN_FRONTEND=noninteractive
USER root

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


USER ${NB_USER}

## Uses packages as at 07/03/2024
ENV RSPM_DATE=2025-04-01
RUN echo "r <- getOption('repos'); \
          r['CRAN'] <- 'https://packagemanager.rstudio.com/cran/__linux__/jammy/${RSPM_DATE}'; \
          options(repos = r);" > ~/.Rprofile && \
          chown ${NB_USER}:${NB_USER} ${HOME}/.Rprofile

USER ${NB_USER}

RUN R -f ${HOME}/install.R

COPY --chown=${NB_USER}:${NB_USER} . ${HOME}/

COPY --from=builder --chown=${NB_USER}:${NB_USER} ${HOME}/.renku/venv ${HOME}/.renku/venv
