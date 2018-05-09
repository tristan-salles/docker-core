FROM debian:jessie

# Should lock that down to a specific version !

ENV VERSION 1.00

MAINTAINER Tristan Salles

## the update is fine but very slow ... keep it separated so it doesn't
## get run again and break the cache. The later parts of this build
## may be sensitive to later versions being picked up in the install phase.

RUN apt-get update -y ;

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends --fix-missing \
        bash-completion \
        build-essential

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends --fix-missing \
        git \
        python \
        python-dev \
        python-pip \
        ruby-full \
        ssh \
        curl \
        rsync \
        vim \
        less \
        zip

## These are for the full python - scipy stack

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    libopenblas-dev \
    liblapack-dev \
    libscalapack-mpi-dev \
    libhdf5-serial-dev \
    libhdf5-openmpi-dev \
    libnetcdf-dev \
    libfreetype6-dev \
    libpng12-dev \
    libtiff-dev \
    libxft-dev \
    petsc-dev \
    xvfb \
    freeglut3 \
    freeglut3-dev \
    libgl1-mesa-dri \
    libgl1-mesa-glx \
    libavcodec-dev \
    libavformat-dev \
    libavutil-dev \
    libswscale-dev \
    gfortran \
    cython \
    libfreetype6-dev \
    python-numpy \
    python-scipy \
    python-matplotlib \
    python-pandas \
    python-sympy \
    python-nose \
    pkg-config
    
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  petsc-dev \
  libhdf5-openmpi-dev \
  xauth
  
RUN pip install --upgrade pip

RUN pip install --no-cache-dir setuptools wheel && \
    pip install --no-cache-dir packaging \
        appdirs \
        numpy \
        jupyter \
        plotly \
        mpi4py \
        matplotlib \
        runipy \
        pillow \
        mpi4py \
        pyvirtualdisplay \
        ipyparallel \
        pint \
        sphinx \
        sphinx_rtd_theme \
        sphinxcontrib-napoleon \
        mock      
        
RUN pip install --no-cache-dir scipy && \
    CC=mpicc HDF5_MPI="ON" HDF5_DIR=/usr/lib/x86_64-linux-gnu/hdf5/openmpi/ pip install --no-cache-dir --no-binary=h5py h5py

RUN pip install mkdocs mkdocs-bootswatch pymdown-extensions\
                stripy \
                litho1pt0 \
                petsc4py
                
# Better to build the latest versions than use the old apt-gotten ones
# I'm putting this here as it takes time and ought to be cached before the
# more ephemeral parts of this image.

# (proj4 is buggered up everywhere in apt-get ... so build a known-to-work version from source)
#
RUN cd /usr/local && \
    curl http://download.osgeo.org/proj/proj-4.9.3.tar.gz > proj-4.9.3.tar.gz && \
    tar -xzf proj-4.9.3.tar.gz && \
    cd proj-4.9.3 && \
    ./configure && \
    make all && \
    make install

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        python-gdal \
        python-pil  \
        libxml2-dev \
        python-lxml \
        libgeos-dev

## The recent netcdf4 / pythonlibrary stuff doesn't work properly with the default search paths etc
## here is a fix which builds the repo version. Hoping that pip install or apt-get install will work again soon

# RUN USE_SETUPCFG=0 HDF5_INCDIR=/usr/include/hdf5/serial HDF5_LIBDIR=/usr/lib/x86_64-linux-gnu/hdf5/serial pip install git+https://github.com/Unidata/netcdf4-python

RUN pip install --upgrade pyproj && \
    pip install --upgrade netcdf4

#
# These ones are needed for cartopy / imaging / geometry stuff
#

RUN pip install appdirs packaging \
              runipy \
              ipython

RUN pip install --no-binary :all: shapely

RUN pip install  \
            pyproj \
            obspy \
            seaborn \
            pandas \
            jupyter \
            https://github.com/ipython-contrib/jupyter_contrib_nbextensions/tarball/master \
            jupyter_nbextensions_configurator

RUN pip install --upgrade cartopy

#RUN jupyter contrib nbextension install --system && \
#    jupyter nbextensions_configurator enable --system

EXPOSE 8888

# Add Tini
# Install Tini.. this is required because CMD (below) doesn't play nice with notebooks for some reason: https
#NOTE: If you are using Docker 1.13 or greater, Tini is included in Docker itself. This includes all versions of Docker CE. To enable Tini, just pass the --init flag to docker run.
RUN curl -L https://github.com/krallin/tini/releases/download/v0.6.0/tini > tini && \
    echo "d5ed732199c36a1189320e6c4859f0169e950692f451c03e7854243b95f4234b *tini" | sha256sum -c - && \
    mv tini /usr/local/bin/tini && \
    chmod +x /usr/local/bin/tini

#ENV TINI_VERSION v0.8.4
#ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/local/bin/tini
#RUN chmod +x /usr/local/bin/tini
