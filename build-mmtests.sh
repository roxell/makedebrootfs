#!/bin/bash

# sha 5ea8d1ce4178 ("common: Wait for ext4 background startup")
RELEASE_VERSION="5ea8d1ce41785527cc571aa6b783ad0257a97bfb"
REPO_URL="https://github.com/gormanm/mmtests"
SRCDIR="/opt/builddir/"
MMTESTS_MAX_RETRIES=10
MMTESTS_CONFIG_FILE="configs/config-scheduler-sysbench-cpu"

# Pre-install packages needed
apt install -y git wget
apt install -y build-essential wget perl git autoconf automake bc binutils-dev btrfs-progs linux-cpupower expect gcc hdparm hwloc-nox libpath-tiny-perl libtool numactl tcl time xfsprogs xfslibs-dev libopenmpi-dev

git clone "${REPO_URL}" "${SRCDIR}"
pushd "${SRCDIR}"
git checkout "${REPO_VERSION}"

# Building
PERL_MM_USE_DEFAULT=1
export PERL_MM_USE_DEFAULT
cpan -f -i JSON Cpanel::JSON::XS List::BinarySearch
AUTO_PACKAGE_INSTALL=yes
export AUTO_PACKAGE_INSTALL
DOWNLOADED=0
COUNTER=0
while [ $DOWNLOADED -eq 0 ] && [ $COUNTER -lt "$MMTESTS_MAX_RETRIES" ]; do
	./run-mmtests.sh -b --no-monitor --config "${MMTESTS_CONFIG_FILE}" benchmark && DOWNLOADED=1
	COUNTER=$((COUNTER+1))
done

popd

apt --purge remove -y git wget build-essential autotools-dev
