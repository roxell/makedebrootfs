FROM debian:buster-slim
RUN apt-get update \
    && apt-get install -qy auto-apt-proxy \
    && apt-get install -qy \
      binfmt-support \
      curl \
      debian-ports-archive-keyring \
      debootstrap \
      file \
      git \
      python3-distutils \
      python3-parted \
      python3-pip \
      python3-requests \
      qemu-user-static \
      sudo \
      xz-utils \
      --no-install-recommends
RUN pip3 install setuptools
RUN pip3 install simplediskimage==0.4
COPY . /makedebrootfs
