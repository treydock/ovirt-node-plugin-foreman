Foreman Discovery oVirt Node Plugin
===================================

Fedora/RHEL based live image for Foreman Discovery plugin based on oVirt Node
project.

Downloading image
-----------------

 * http://yum.theforeman.org/discovery/

Nightly builds has ssh daemon enabled and root password set to "redhat" and
logging is increased while releases do have root account locked and there is
no ssh access at all. We provide images based on the following distributions:

 * Fedora 18
 * CentOS 6

First console (tty1) is reserved for Discovery output, if you want to log in
use tty2 or higher console.

Minimal hardware requirements
-----------------------------

Since the live image runs from memory, keep in mind the following minimum
requirements on the hardware that is being discovered:

* 700 MB RAM for CentOS6 image
* 900 MB RAM for Fedora19 image

When testing those images on hypervisors, make sure you allocated enough
memory, otherwise kernel panic can be seen during boot sequence.

Installation
------------

Download either both kernel and image RAM disk:

 * ovirt-node-iso-3.X.0-0.999.201404170648.el6.iso-img
 * ovirt-node-iso-3.X.0-0.999.201404170648.el6.iso-vmlinuz

or ISO file:

 * ovirt-node-iso-3.X.0-0.999.201404170648.el6.iso

If you downloaded kernel and image, you can skip to Set Foreman bellow. If you
downloaded the ISO file, you need to extract it first:

    # yum -y install livecd-tools
    # ln -sf ovirt-node-iso-3.X.0-0.999.201404170648.el6.iso foreman.iso
    # sudo livecd-iso-to-pxeboot foreman.iso
    # find tftpboot/
    tftpboot/
    tftpboot/vmlinuz0
    tftpboot/pxelinux.0
    tftpboot/pxelinux.cfg
    tftpboot/pxelinux.cfg/default
    tftpboot/initrd0.img

Now, copy *vmlinuz0* and *initrd0.img* files to your TFTP BOOT directory and
rename them appropriately.

Set Foreman
-----------

To activate Foreman Discovery edit *PXELinux global default* template and add
new menu item:

    LABEL discovery
    MENU LABEL Foreman Discovery
    MENU DEFAULT
    KERNEL boot/tftpboot/vmlinuz0
    APPEND rootflags=loop initrd=boot/tftpboot/initrd0.img root=live:/foreman.iso rootfstype=auto ro rd.live.image rd.live.check rd.lvm=0 rootflags=ro crashkernel=128M elevator=deadline max_loop=256 rd.luks=0 rd.md=0 rd.dm=0 nomodeset selinux=0 stateless foreman.url=https://foreman.example.com
    IPAPPEND 2

To set the menu item default, change the above snippet to something like

    DEFAULT menu
    PROMPT 0
    MENU TITLE PXE Menu
    TIMEOUT 200
    TOTALTIMEOUT 6000
    ONTIMEOUT discovery

Note the `foreman.url` that defines where foreman instance really is. You can
use both https or http. Make sure this is set correctly.

Discovery image searches for DNS SRV record named `_x-foreman._tcp`. If you
setup your DNS server for that (example for ISC BIND), then you do not need to
provide `foreman.url`:

    _x-foreman._tcp SRV 0 5 443 foreman

This can still be overriden with the command line opts.

It is important to have *IPAPPEND 2* option which adds BOOTIF=MAC option which
is then reported via facter as `discovery_bootif` which is key fact which is
used for provisioning.

_Warning_: For now, you need to provide selinux=0 option, the image is read
only anyway but we plan to enable and test with SELinux too.

Building the plugin
-------------------

Building the plugin is easy, it is built around autotools. You can provide
option to enable debugging mode image:

    make distclean
    ./autogen.sh --enable-debug

Building
--------

Building is tested currently on Fedora 18 and RHEL 6.5 or clones.

Follow instructions on [oVirt
wiki](http://www.ovirt.org/Node_Building#From_Git) to build the image.

We have a build script that is Vagrant ready, so it is easy to build your own
images easily. We provide clean distro images created with
[virt-builder](http://libguestfs.org/virt-builder.1.html) and enhanced with
[vagrantify](https://github.com/domcleal/vagrantify). Those will be
automatically downloaded when using our Vagrant file.

The Vagrant file will spawn an image according the options, build the oVirt
Node plugin and build the image.
