#!/bin/bash
# vim: sw=2:ts=2:et
set -x
PLUGIN=ovirt-node-plugin-foreman
export debug=${1:-debug}
export proxy_repo=${2:-http://yum.theforeman.org/nightly/el6/x86_64/}
export repoowner=${3:-theforeman}
export branch=${4:-master}
export ovirt_node_tools_gittag=${5:-master}
export WITH_GIT_BRANCH=${6:-master}

# give the VM some time to finish booting and network configuration
sleep 30
yum -y install epel-release

yum -y install livecd-tools appliance-tools-minimizer fedora-packager \
  python-devel rpm-build createrepo selinux-policy-doc checkpolicy \
  selinux-policy-devel autoconf automake python-mock python-lockfile \
  python-nose pykickstart git-review qemu-kvm hardlink git wget

sed -r -i 's/^(Defaults\s+requiretty)/#\1/g' /etc/sudoers

# build plugin
pushd /root
SELINUXMODE=$(getenforce)
setenforce 1
export OVIRT_NODE_BASE=$PWD
export OVIRT_CACHE_DIR=~/ovirt-cache
export OVIRT_LOCAL_REPO=file://${OVIRT_CACHE_DIR}/ovirt
export REPO="$proxy_repo"
mkdir -p $OVIRT_CACHE_DIR
[ -d $PLUGIN ] || git clone --depth 1 https://github.com/$repoowner/$PLUGIN.git -b $branch
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
  git checkout -b $ovirt_node_tools_gittag tags/$ovirt_node_tools_gittag
  popd
pushd dev-utils
[ -d ovirt-node ] || make install-build-requirements clone-repos git-update WITH_GIT_BRANCH=$WITH_GIT_BRANCH
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
mv node-ws/dev-utils/ovirt-node-iso/*iso .
cp node-ws/dev-utils/ovirt-node-iso/ovirt-node-iso.ks .
cat ovirt-node-base-iso.ks
rm -rf tftpboot/ foreman.iso
ISO=$(ls *iso | head -n1)
ln -fs $ISO foreman.iso
livecd-iso-to-pxeboot foreman.iso
mv -f tftpboot/vmlinuz0 $ISO-vmlinuz
mv -f tftpboot/initrd0.img $ISO-img
ls *iso -la
popd
setenforce $SELINUXMODE
