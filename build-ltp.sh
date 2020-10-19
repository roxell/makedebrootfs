#!/bin/bash

RELEASE_VERSION="20200930"
RELEASE_TESTSUITE_NAME="ltp-full-"${RELEASE_VERSION}".tar.xz"
RELEASE_TAR_URL="https://github.com/linux-test-project/ltp/releases/download/"${RELEASE_VERSION}"/"${RELEASE_TESTSUITE_NAME}""
SRCDIR="/opt/builddir/"

# Pre-install packages needed
apt install -y git wget
apt install -y xz-utils flex bison build-essential curl net-tools quota genisoimage sudo libaio-dev expect automake acl

mkdir -p "${SRCDIR}"
pushd "${SRCDIR}"
wget "${RELEASE_TAR_URL}"
tar --strip-components=1 -Jxf "${RELEASE_TESTSUITE_NAME}"

# Building
./configure
make -j8 all
make SKIP_IDCHECK=1 install

popd
rm -rf "${SRCDIR}"

apt --purge remove -y git wget build-essential
