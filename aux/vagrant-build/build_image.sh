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
type git || yum -y install git

# build plugin
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
        https://git.fedorahosted.org/cgit/appliance-tools.git/plain/tools/image-minimizer
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
mv node-ws/dev-utils/ovirt-node-iso/*iso .
ls *iso -la
