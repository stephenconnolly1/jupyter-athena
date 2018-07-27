FROM jupyter/minimal-notebook

# Installs the Simba ODBC driver into the Jupyter image to allow
# direct queries of Athena from Jupyter Notebook
MAINTAINER Stephen Connolly <stephen.connolly@capgemini.com>

USER root

# Install alien utility needed to install the ODBC driver
RUN apt-get update && apt-get install -yq --no-install-recommends \
    alien \
    unixodbc-dev \
    unixodbc-bin \
    unixodbc \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install the Simba 32/64 bit ODBC driver
RUN wget https://s3.amazonaws.com/athena-downloads/drivers/ODBC/Linux/simbaathena-1.0.2.1003-1.x86_64.rpm && \
    alien -i simbaathena-1.0.2.1003-1.x86_64.rpm && \
    rm -f simbaathena-1.0.2.1003-1.x86_64.rpm

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID

RUN conda install --yes -c anaconda  \
    'boto3'  \
    'pandas'  \
    && conda clean -tipsy && \
    fix-permissions $CONDA_DIR

# move to ODBC configuration
# Define Location of ODBC driver libraries and config files
ENV LD_LIBRARY_PATH /opt/conda/pkgs/unixodbc-2.3.6-h1bed415_0/lib
ENV ODBCINI /opt/simba/athenaodbc/Setup/odbc.ini
ENV ODBCSYSINI /opt/simba/athenaodbc/Setup
ENV SIMBA_ATHENA_ODBC_INI /opt/simba/athenaodbc/lib/64/simba.athenaodbc.ini

## Build pyodbc with the 600 char limit fixed
## TODO just install 'pyodbc' from conda once the fix is released.
USER root
WORKDIR /src
RUN git clone -b remove-connstr-limit --single-branch https://github.com/v-chojas/pyodbc.git && \
cd pyodbc && \
python3 setup.py build && \
python3 setup.py install

WORKDIR /home/jovyan
RUN rm -rf /src

USER $NB_UID
