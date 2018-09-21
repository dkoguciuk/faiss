###############################################################################
# Info
###############################################################################

FROM nvidia/cuda:8.0-devel-ubuntu16.04
MAINTAINER Pierre Letessier <pletessier@ina.fr>

###############################################################################
# Install dependencies
###############################################################################

RUN apt-get update -y
RUN apt-get install -y libopenblas-dev python-numpy python-dev swig git python-pip curl
RUN pip install --upgrade pip
RUN pip2 install matplotlib

###############################################################################
# Copy repo files
###############################################################################

COPY . /opt/faiss

###############################################################################
# ENV setup
###############################################################################

ENV BLASLDFLAGS /usr/lib/libopenblas.so.0

###############################################################################
# make cpu
###############################################################################

WORKDIR /opt/faiss

RUN ./configure && \
    make -j $(nproc) && \
    make test && \
    make install

###############################################################################
# make gpu
###############################################################################

RUN make -C gpu -j $(nproc) && \
    make -C gpu/test

###############################################################################
# make python interface
###############################################################################

RUN make -C python gpu && \
    make -C python build && \
    make -C python install

###############################################################################
# ENV setup
###############################################################################

ENV PYTHONPATH $PYTHONPATH:/opt/faiss
