#!/bin/bash

ARCH=${ARCH:-arm64}

./setup-rootfs.sh -a ${ARCH} -r buster -p build-rteval.sh 2>&1 >output-${ARCH}-rteval.log &
./setup-rootfs.sh -a ${ARCH} -r buster -p build-fwts.sh 2>&1 >output-${ARCH}-fwts.log &
./setup-rootfs.sh -a ${ARCH} -r buster -p build-ltp.sh 2>&1 >output-${ARCH}-ltp.log &
./setup-rootfs.sh -a ${ARCH} -r buster 2>&1 >output-${ARCH}.log &
