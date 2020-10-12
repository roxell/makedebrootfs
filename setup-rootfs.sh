#!/bin/bash

# sudo apt-get install debootstrap qemu-user-static binfmt-support debian-ports-archive-keyring

set -ex

ROOTPATH=$(dirname $(readlink -f $0))

if [[ -f ${HOME}/.ragnar.rc ]]; then
    source ${HOME}/.ragnar.rc
else
    TOP=${TOP:-"${HOME}"}
fi
TOP=${TOP}/rootfs-artifacts

mkdir -p ${TOP}

ARCH="arm64"
RELEASE="buster"
EXTRA_DEBOOT_STUFF=""
EXTRA_PACKAGES=""
OUTPUT_DIRNAME="base"

usage() {
    echo -e "$0's help text"
    echo -e "$0 [-a ARCH] [-p '']"
    echo -e "-a ARCH, architecture default: arm64"
    echo -e "-p '', add file names, separate them with space."
    echo -e "-r RELEASE, debian release, default: buster"
}

while getopts "a:hp:r:" arg; do
    case $arg in
        a)
            ARCH="$OPTARG"
            ;;
        p)
            EXTRA_PACKAGES="$OPTARG"
            ;;
        r)
            RELEASE="$OPTARG"
            ;;
        h|*)
            usage
            exit 0
            ;;
    esac
done


EXTRA_DEBOOT_STUFF="http://ftp.se.debian.org/debian/ --include=systemd-sysv"
if [[ ${ARCH} == "riscv64" ]]; then
    EXTRA_DEBOOT_STUFF="--keyring /usr/share/keyrings/debian-ports-archive-keyring.gpg --include=debian-ports-archive-keyring http://deb.debian.org/debian-ports"
    RELEASE=unstable
fi

if [[ -n ${EXTRA_PACKAGES} ]]; then
    for file in ${EXTRA_PACKAGES}; do
        OUTPUT_DIRNAME=$OUTPUT_DIRNAME-$(echo ${file}|awk -F'-' '{print $2}'|awk -F'.' '{print $1}')
    done
fi

OUTPUTDIR=${TOP}/$(date +"%Y%m%d-%H%m")/${OUTPUT_DIRNAME}
BUILDDIR=${RELEASE}/${ARCH}/${OUTPUT_DIRNAME}
mkdir -p ${OUTPUTDIR}
mkdir -p tmp/${BUILDDIR}
sudo chown root:root tmp/${BUILDDIR}
cd tmp

# remove --no-merged-usr when LAVA is fixed and can handle symlinks
sudo qemu-debootstrap --no-merged-usr --arch=${ARCH} ${RELEASE} ${BUILDDIR} ${EXTRA_DEBOOT_STUFF}

sudo chroot ${BUILDDIR} passwd --delete root

cat >> 80-dhcp.network << EOF
[Match]
Name=en*
[Network]
DHCP=yes
EOF
sudo mv --force 80-dhcp.network ${BUILDDIR}/etc/systemd/network/

cat >> rc-local.service << EOF
[Unit]
Description=/etc/rc.local
ConditionPathExists=/etc/rc.local

[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99

[Install]
WantedBy=multi-user.target
EOF
sudo mv --force rc-local.service ${BUILDDIR}/etc/systemd/system/

cat >> "rc.local" << EOF
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.
 
exit 0
EOF
sudo mv --force "rc.local" ${BUILDDIR}/etc/

sudo chmod +x ${BUILDDIR}/etc/rc.local
sudo chroot ${BUILDDIR} systemctl enable rc-local

sudo chroot ${BUILDDIR} systemctl enable systemd-networkd
echo "nameserver 8.8.8.8" | sudo tee ${BUILDDIR}/etc/resolv.conf
echo "debian" | sudo tee ${BUILDDIR}/etc/hostname

#sed -ie 's|\.de\.|.se.|g' ${BUILDDIR}/etc/apt/sources.list

for file in ${EXTRA_PACKAGES}; do
    sudo cp ${ROOTPATH}/${file} ${BUILDDIR}/root/
    sudo chroot ${BUILDDIR} bash ./root/${file}
done
# mount -t tmpfs tmp /tmp
#echo "tmpfs   /tmp         tmpfs   rw,nodev,nosuid,size=1G          0  0" | sudo tee -a ${BUILDDIR}/etc/fstab

cd ${BUILDDIR}
sudo tar -cJvf ${OUTPUTDIR}/debian-${RELEASE}-${ARCH}-rootfs.tar.xz .
## vim: set sw=4 sts=4 et foldmethod=syntax : ##
