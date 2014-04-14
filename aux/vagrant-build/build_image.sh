#!/bin/bash
# vim: sw=2:ts=2:et
set -x
PLUGIN=ovirt-node-plugin-foreman
debug=${1:-debug}
proxy_repo=${2:-http://yum.theforeman.org/releases/1.4/el6/x86_64/}
repoowner=${3:-theforeman}
branch=${4:-master}

# give the VM some time to finish booting and network configuration
sleep 30
yum -y install livecd-tools appliance-tools-minimizer fedora-packager \
  python-devel rpm-build createrepo selinux-policy-doc checkpolicy \
  selinux-policy-devel autoconf automake python-mock python-lockfile \
  python-nose git-review qemu-kvm hardlink git wget

# build plugin
pushd /root
SELINUXMODE=$(getenforce)
setenforce 1
export OVIRT_NODE_BASE=$PWD
export OVIRT_CACHE_DIR=~/ovirt-cache
export OVIRT_LOCAL_REPO=file://${OVIRT_CACHE_DIR}/ovirt
export REPO="$proxy_repo"
mkdir -p $OVIRT_CACHE_DIR
[ -d $PLUGIN ] || git clone https://github.com/$repoowner/$PLUGIN.git -b $branch
pushd $PLUGIN
git pull
if [[ "$debug" == "debug" ]]; then
  ./autogen.sh --enable-debug && make rpms publish
else
  ./autogen.sh && make rpms publish
fi
popd

# build iso
rm -f *.iso
wget -O /usr/bin/image-minimizer -c -N \
  https://git.fedorahosted.org/cgit/lorax.git/plain/src/bin/image-minimizer
chmod +x /usr/bin/image-minimizer
mkdir node-ws 2>/dev/null
pushd node-ws
[ -d ovirt-node-dev-utils ] || \
  git clone https://github.com/fabiand/ovirt-node-dev-utils.git dev-utils
pushd dev-utils
[ -d ovirt-node ] || make install-build-requirements clone-repos
grep $PLUGIN ovirt-node/recipe/common-pkgs.ks || \
  echo $PLUGIN >> ovirt-node/recipe/common-pkgs.ks
if [[ "$debug" == "debug" ]]; then
  sed -i 's/.*passwd -l root/#passwd -l root/g' ovirt-node/recipe/common-post.ks
else
  sed -i 's/.*passwd -l root/passwd -l root/g' ovirt-node/recipe/common-post.ks
fi
make iso | tee ../../make_iso.log
popd
popd
rm -rf tftpboot/
ISO=$(ls *iso | head -n1)
mv node-ws/dev-utils/ovirt-node-iso/*iso .
livecd-iso-to-pxeboot $ISO
mv -f tftpboot/vmlinuz0 $ISO-vmlinuz
mv -f tftpboot/initrd.img $ISO-img
ls *iso -la
popd
setenforce $SELINUXMODE
