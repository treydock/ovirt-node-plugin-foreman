Foreman Discovery oVirt Node Plugin
===================================

Fedora/RHEL based live image for Foreman Discovery plugin based on oVirt Node
project.

Download and installation
-------------------------

Head over to the [foreman
discovery](https://github.com/theforeman/foreman_discovery) README to find out
more.

Building the plugin
-------------------

Building the plugin is easy, it is built around autotools. You can provide
option to enable debugging mode image:

    make distclean
    ./autogen.sh --enable-debug

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

Building on our Jenkins instance
--------------------------------

If you have access to our Jenkins instance (Foreman core or community
developers do) you can clone this repository, push changes into branch and
[trigger](http://ci.theforeman.org/view/Packaging/job/packaging_discovery_node/)
new build after sign-in giving the job `repoowner` and `branch` name and
`output_dir` in a format of scratch-myname. Result will be available on our
[official yum repo server](http://yum.theforeman.org/discovery/).

You can also build using Vagrant which is usually faster, see above.

