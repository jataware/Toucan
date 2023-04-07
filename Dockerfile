FROM ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Moscow
RUN apt-get update && apt-get install -y \
      apt-utils \
      build-essential \
      cmake \
      gfortran \
      git \
      libssl-dev \
      maven \
      python3-pip \
      python3-rtree \
      python3.8-dev \
      sudo && \
      apt-get -y autoremove && apt-get clean autoclean


RUN mkdir codebase && \
      cd codebase && \
      git clone https://github.com/dssat/dssat-csm-os && \
      cd dssat-csm-os && \
      mkdir release && \
      cd release && \
      cmake -DCMAKE_BUILD_TYPE=Release .. && \
      make

COPY . /codebase/Toucan

RUN cd /codebase/Toucan && \
      mvn install && \
      mvn compile && \
      mvn package && \
      cd /codebase/Toucan/res && \
      mkdir -p .csm .temp result threads && \
      cp -r /codebase/dssat-csm-os/Data/* ./.csm && \
      cp -r /codebase/dssat-csm-os/Data/Genotype/* ./.csm && \
      cp -r /codebase/dssat-csm-os/Data/Pest/* ./.csm && \
      cp -r /codebase/dssat-csm-os/Data/StandardData/* ./.csm && \
      cp -r /codebase/dssat-csm-os/release/bin/dscsm048 ./.csm/DSCSM048.EXE && \
      cd /codebase/Toucan/res/.temp && \
      mkdir summary multipleplanting flowering planting error

# COPY ./cultivars/.csm /codebase/Toucan/res/.csm

RUN pip install PyYAML

WORKDIR /codebase/Toucan

# ENTRYPOINT [ "java", "-cp", "target/ToucanSNX-1.0-SNAPSHOT.jar:lib/*", "org.cgiar.toucan.App" ]
# CMD [ "ETH", "4" , "0" ]
ENTRYPOINT [ "python3", "./docker-scripts/execute_model.py" ]