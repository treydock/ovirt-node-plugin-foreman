Foreman Discovery oVirt Node Plugin
===================================

Fedora/RHEL based live image for Foreman Discovery plugin based on oVirt Node
project.

Downloading image
-----------------

We provide download links on the [Foreman Discovery plugin
page](https://github.com/theforeman/foreman_discovery):

 * http://yum.theforeman.org/discovery/

You can download four versions:

 * Fedora based, production
 * RHEL based, production
 * Fedora based, debug
 * RHEL based, debug

The production images have the root account locked and there is no ssh daemon
running on the image.

On the debug images, the root password is set to "redhat" and ssh daemon is
listening on the standard port. Also logging of discover-host and
foreman-proxy services is increased to DEBUG level.

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

Setup Foreman templates
-----------------------

To setup Foreman templates head over to [Foreman Discovery plugin
page](https://github.com/theforeman/foreman_discovery).

