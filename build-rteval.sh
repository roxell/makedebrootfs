#!/bin/bash

# Only until rt-tests will be using the latest rt-tests release as a deb package.
REPO_VERSION="v1.8"
REPO_URL="https://git.kernel.org/pub/scm/utils/rt-tests/rt-tests.git"
SRCDIR="/opt/builddir/"

# Pre-install packages needed
apt install -y git build-essential libnuma-dev python3-dev


git clone "${REPO_URL}" "${SRCDIR}"
pushd "${SRCDIR}"
git checkout "${REPO_VERSION}"

# Building
make
make install
popd
rm -rf "${SRCDIR}"

# Installing rteval

# Pre-install packages needed
apt install -y curl git python3-dev python3-schedutils python3-ethtool python3-lxml python3-dmidecode rt-tests sysstat xz-utils bzip2 tar numactl build-essential flex bison bc elfutils openssl libssl-dev cpio libelf-dev binutils linux-libc-dev keyutils libaio-dev attr libpcap-dev lksctp-tools zlib1g-dev util-linux

openssl req -new -nodes -utf8 -sha256 -days 36500 -batch -x509 -config x509.genkey -outform PEM -out kernel_key.pem -keyout kernel_key.pem || true

#REPO_VERSION="master"
REPO_URL="https://git.kernel.org/pub/scm/utils/rteval/rteval.git"
SRCDIR="/opt/rteval/"

git clone "${REPO_URL}" "${SRCDIR}"
pushd "${SRCDIR}"
git log --oneline -1 >.rteval_git_version
popd

apt --purge remove -y git
