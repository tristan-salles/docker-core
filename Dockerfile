FROM debian:jessie

# Should lock that down to a specific version !

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
        gfortran \
        cython \
        cmake \
        zip

## Compile petsc
RUN cd /usr/local && \
    git clone https://bitbucket.org/petsc/petsc petsc && \
    cd petsc && \
    export PETSC_VERSION=3.8.4 && \
    git checkout tags/v$PETSC_VERSION && \
    ./configure --CFLAGS='-O3' --CXXFLAGS='-O3' --FFLAGS='-O3' --with-debugging=no --download-openmpi=yes --download-hdf5=yes --download-fblaslapack=yes --download-metis=yes --download-parmetis=yes && \
    make PETSC_DIR=/usr/local/petsc PETSC_ARCH=arch-linux2-c-opt all

## These are for the full python - scipy stack

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    libopenblas-dev \
    liblapack-dev \
    libscalapack-mpi-dev \
    libhdf5-serial-dev \
    petsc-dev \
    libhdf5-openmpi-dev \
    xauth \
    libnetcdf-dev \
    libfreetype6-dev \
    libpng12-dev \
    libtiff-dev \
    libxft-dev \
    xvfb \
    freeglut3 \
    freeglut3-dev \
    libgl1-mesa-dri \
    libgl1-mesa-glx \
    libavcodec-dev \
    libavformat-dev \
    libavutil-dev \
    libswscale-dev \
    libfreetype6-dev \
    python-numpy \
    python-scipy \
    python-matplotlib \
    python-pandas \
    python-sympy \
    python-nose \
    pkg-config

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
        python-h5py \
        libxml2-dev \
        python-lxml \
        libgeos-dev

## The recent netcdf4 / pythonlibrary stuff doesn't work properly with the default search paths etc
## here is a fix which builds the repo version. Hoping that pip install or apt-get install will work again soon
RUN pip install --upgrade pip && \
    pip install matplotlib numpy scipy --upgrade && \
    pip install --upgrade pyproj && \
    pip install --upgrade netcdf4
