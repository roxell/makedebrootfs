#!/bin/bash

RELEASE_VERSION="V20.09.00"
REPO_URL="https://github.com/ColinIanKing/fwts"
SRCDIR="/opt/builddir/"

# Pre-install packages needed
apt install -y git wget
#apt install -y autoconf automake libglib2.0-dev libtool libpcre3-dev flex bison dkms libfdt-dev libbsd-dev
apt install -y build-essential libglib2.0-dev libtool libpcre3-dev flex bison dkms libfdt-dev libbsd-dev

#mkdir -p "${SRCDIR}"
#pushd "${SRCDIR}"
#wget https://github.com/ColinIanKing/fwts/archive/"${RELEASE_VERSION}".tar.gz
#tar --strip-components=1 -zxf "${RELEASE_VERSION}".tar.gz
git clone "${REPO_URL}" "${SRCDIR}"
pushd "${SRCDIR}"
git checkout "${REPO_VERSION}"

# Building
autoreconf -ivf
./configure --prefix=/
make -j8 all
make install

popd
rm -rf "${SRCDIR}"

sudo apt --purge remove -y git wget build-essential
