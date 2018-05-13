FROM ubuntu:16.04

MAINTAINER Tristan Salles

RUN apt-get update -y && \
          apt-get install -y --no-install-recommends apt-utils

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
          autoconf \
          automake \
          libtool

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends --fix-missing \
        bash-completion \
        build-essential \
        cmake \
        gfortran \
        gcc \
        xauth \
        git \
        git-core \
        libblas-dev \
        python-dev \
        python-pip \
        mpich \
        mercurial \
        libspatialindex-dev \
        libmpich-dev \
        liblapack-dev \
        libopenblas-dev \
        wget \
        zip \
        openssh-server \
        python-setuptools \
        python-numpy \
        python-scipy \
        python-matplotlib \
        python-pandas \
        python-sympy \
        python-nose \
        pkg-config \
        zlib1g-dev

RUN pip install six

RUN mkdir /live && \
         mkdir /live/lib

RUN cd /live/lib && \
        wget https://support.hdfgroup.org/ftp/HDF5/current/src/hdf5-1.10.1.tar  && \
        tar -xvf hdf5-1.10.1.tar && \
        cd hdf5-1.10.1 && \
        CC=mpicc.mpich FC=mpif90.mpich ./configure --prefix=/usr/local/hdf5 --enable-parallel --enable-fortran && \
        make && \
        make install && \
        cd /live/lib && \
        rm -rf hdf5-1.10.1 && \
        rm -rf hdf5-1.10.1.tar
        
RUN cd /live/lib && \
        git clone https://bitbucket.org/petsc/petsc.git && \
        cd petsc && \
        export PETSC_VERSION=3.8.4 && \
        git checkout tags/v$PETSC_VERSION

RUN cd /live/lib/petsc && \
        ./configure --CFLAGS='-O3' --CXXFLAGS='-O3' --FFLAGS='-O3' --with-debugging=no  --with-hdf5-dir=/usr/local/hdf5 --download-fblaslapack --download-ctetgen --download-metis=yes --download-parmetis=yes --download-triangle

RUN cd /live/lib/petsc && \
        make  PETSC_DIR=/live/lib/petsc PETSC_ARCH=arch-linux2-c-opt all

RUN cd /live/lib/petsc && \
        make PETSC_DIR=/live/lib/petsc PETSC_ARCH=arch-linux2-c-opt test && \
        make PETSC_DIR=/live/lib/petsc PETSC_ARCH=arch-linux2-c-opt streams NPMAX=4

RUN pip install --upgrade pip
RUN pip install numpy mpi4py

RUN cd /live/lib/petsc && \
      make PETSC_DIR=/live/lib/petsc PETSC_ARCH=arch-linux2-c-opt check

RUN cd /live/lib/ && \
        wget https://bitbucket.org/petsc/petsc4py/downloads/petsc4py-3.8.1.tar.gz && \
        tar -xzf petsc4py-3.8.1.tar.gz && \
        cd petsc4py-3.8.1 && \
        export PETSC_DIR=/live/lib/petsc && \
        export PETSC_ARCH=arch-linux2-c-opt && \
        python setup.py install

RUN pip install cython
RUN CC="mpicc.mpich" HDF5_MPI="ON" HDF5_DIR=/usr/local/hdf5 pip install --no-binary=h5py h5py 
#RUN cd /live/lib/ && \
#          wget https://pypi.python.org/packages/source/h/h5py/h5py-2.5.0.tar.gz && \
#          tar zxvf h5py-2.5.0.tar.gz && \
#          cd h5py-2.5.0/ && \
#          python setup.py configure --hdf5=/usr/local/hdf5/ && \
#          env CFLAGS=-I/usr/lib/mpich/include python setup.py install

RUN DEBIAN_FRONTEND=noninteractive apt-get remove -y --no-install-recommends python-pip
RUN pip install stripy \
                litho1pt0

RUN pip install enum34
RUN pip install jupyter markupsafe zmq singledispatch backports_abc certifi jsonschema ipyparallel path.py
