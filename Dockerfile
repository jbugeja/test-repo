# Latest alpine base image
FROM alpine:latest as python2-builder

# Install build dependencies for python 2
RUN apk add --no-cache build-base \
  libffi-dev \
  openssl-dev \
  zlib-dev \
  bzip2-dev \
  xz-dev \
  readline-dev \
  sqlite-dev

# Download and compile python 2 from source
RUN wget https://www.python.org/ftp/python/2.7.18/Python-2.7.18.tar.xz && \
  tar xf Python-2.7.18.tar.xz && \
  cd Python-2.7.18 && \
  ./configure --enable-optimizations && \
  make && \
  make altinstall

# Create a symlink to call python2.7 with python2
RUN ln -s /usr/local/bin/python2.7 /usr/local/bin/python2

# Install pip for python 2
RUN wget https://bootstrap.pypa.io/pip/2.7/get-pip.py && \
  python2 get-pip.py

# Start from alpine base image
FROM alpine:latest

# Copy python 2 from the builder stage
COPY --from=python2-builder /usr/local /usr/local

# Set the working directory
WORKDIR /app

# Install python 3 and R
RUN apk add --no-cache \
  python3 \
  py3-pip \
  R \
  libxml2-dev \
  libxslt-dev \
  build-base

# Copy and install python and R requirements
COPY requirements-py2.txt /tmp/
COPY requirements-py3.txt /tmp/
RUN python2 -m pip install -r /tmp/requirements-py2.txt
RUN python3 -m pip install -r /tmp/requirements-py3.txt
RUN R -e "options(repos = list(CRAN = 'http://cran.rstudio.com')); install.packages('dplyr')"

# Create user
RUN adduser -D swishtest
USER swishtest
