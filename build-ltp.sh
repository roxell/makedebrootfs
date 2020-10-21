#!/bin/bash

RELEASE_VERSION="20200930"
REPO_URL="https://github.com/linux-test-project/ltp.git"
SRCDIR="/opt/builddir/"

# Pre-install packages needed
apt install -y git wget
apt install -y xz-utils flex bison build-essential curl net-tools quota genisoimage sudo libaio-dev expect automake acl m4 libattr1-dev libcap-dev autotools-dev autoconf pkgconf

git clone "${REPO_URL}" "${SRCDIR}"
pushd "${SRCDIR}"
git checkout "${REPO_VERSION}"

# Building
make autotools
./configure
make -j8 all
make SKIP_IDCHECK=1 install

popd
rm -rf "${SRCDIR}"

apt --purge remove -y git wget build-essential autotools-dev
