FROM ubuntu:17.10
MAINTAINER Rafal Pronko


RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get -y install software-properties-common python-software-properties
RUN add-apt-repository main
RUN add-apt-repository universe
RUN add-apt-repository restricted
RUN add-apt-repository multiverse
RUN echo "deb http://us.archive.ubuntu.com/ubuntu/ yakkety universe" | tee -a /etc/apt/sources.list

RUN apt-get update
RUN apt-get upgrade


RUN apt-get -y install build-essential cmake git pkg-config \
               libjpeg8-dev libtiff5-dev libjasper-dev \
               libavcodec-dev libavformat-dev libswscale-dev libv4l-dev \
               libgtk2.0-dev \
               libatlas-base-dev gfortran \
               curl \
               wget \
               vim \
               htop \
               libmysqlclient-dev \
               build-essential \
               libgoogle-glog-dev \
               libprotobuf-dev \
               protobuf-compiler \
               libsqlite3-dev \
               sqlite3



RUN apt-get -y install python3.6 python3.6-dev

RUN apt-get clean

RUN wget http://mirrors.kernel.org/ubuntu/pool/main/libp/libpng/libpng12-0_1.2.54-1ubuntu1_amd64.deb
RUN dpkg -i libpng12-0_1.2.54-1ubuntu1_amd64.deb
RUN apt-get -y install libhdf5-serial-dev
RUN apt-get -y install python3-pip

# Install Tini
RUN curl -L https://github.com/krallin/tini/releases/download/v0.6.0/tini > tini && \
    echo "d5ed732199c36a1189320e6c4859f0169e950692f451c03e7854243b95f4234b *tini" | sha256sum -c - && \
    mv tini /usr/local/bin/tini && \
    chmod +x /usr/local/bin/tini




# Add a notebook profile.
RUN mkdir -p -m 700 /root/.jupyter/ && \
    echo "c.NotebookApp.ip = '*'" >> /root/.jupyter/jupyter_notebook_config.py

VOLUME /notebooks
WORKDIR /notebooks


RUN pip3 --no-cache-dir install ipykernel
RUN python3 -m ipykernel.kernelspec
RUN rm -rf /root/.cache

ADD requirments.txt /notebooks
RUN pip3 install --upgrade pip setuptools
RUN pip3 install -r requirments.txt
RUN pip3 install ipywidgets jupyter nbextension enable --py widgetsnbextension

RUN python3 -m spacy download en

EXPOSE 8888

ENTRYPOINT ["tini", "--"]
CMD ["jupyter", "notebook", "--no-browser", "--allow-root"]
