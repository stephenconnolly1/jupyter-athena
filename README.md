# Athena Jupyter Notebook

An example showing how to build and run a Docker container that hosts
Jupyter notebook and includes runtimes and drivers to allow a
user to execute SQL statements against an existing table defined in Athena, using pyodbc and the Simba Athena ODBC drivers.


## Build instructions

The example runs in a Docker machine for Windows environment. It will need some small adjustments to run in an Ubuntu or Mac environment.

The host volume in particular is hard coded to reference a source path mapped manually in the VirtualBox environment. This is because by default only the c:\Users folder is mapped in the `default` Docker machine, and my source code is held on the D:\ drive. This mechanism allows notebooks and source files edited in the notebook to be persisted in the source directory and checked into source control.

Use `run.sh` to build the Docker image and start it. The Athena Jupyter notebook requires a number of environment variables that defined sensitive information.

I would recommend installing direnv and creating a file called `.envrc` in the root folder that defines values for the environment variables.
This file is included in `.gitignore` so that sensitive data will not be checked into source control. A template `.envrc.template` file is provided that lists all the relevant environment variables.

Once the Jupyter notebook has started you should identify the IP of the container using e.g. `docker-machine ip` and browse to http://DOCKER-IP:8888. The Athena notebook is in http://DOCKER-IP:8888/notebooks/work/Athena.ipynb


## Notes

The current release version of the pyodbc library has an arbitrary limit of 600 characters on ODBC connection strings. The Docker image build pulls down a code branch that removes this limitation, builds it and installs it. In due course when the fix has been merged to the master branch and released the dockerfile can be updated to pull pyodbc directly from Anaconda.
