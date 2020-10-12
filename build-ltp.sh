#!/bin/bash

LTP_VERSION=20200930
apt install -y git
apt install -y xz-utils flex bison build-essential curl net-tools quota genisoimage sudo libaio-dev expect automake acl

git clone https://github.com/linux-test-project/ltp.git
pushd ltp
git checkout "${LTP_VERSION}"

./configure
make -j8 all
make SKIP_IDCHECK=1 install

popd
rm -rf ltp


sudo apt --purge remove -y git build-essential
