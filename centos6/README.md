# CentOS 6 Packer Template for MAAS

## Introduction

The Packer template in this directory creates a CentOS 6 AMD64 image for use with MAAS.

## Prerequisites (to create the image)

* A machine running Ubuntu 18.04+ with the ability to run KVM virtual machines.
* qemu-utils, libnbd-bin, nbdkit and fuse2fs
* [Packer.](https://www.packer.io/intro/getting-started/install.html), v1.7.0 or newer

## Requirements (to deploy the image)

* [MAAS](https://maas.io) any version.

## Customizing the Image

The deployment image may be customized by modifying http/centos6.ks. See the [CentOS kickstart documentation](https://docs.centos.org/en-US/centos/install-guide/Kickstart2/) for more information.

## Building the image using a proxy

The Packer template downloads the CentOS net installer from the Internet.
To tell Packer to use a proxy set the HTTP_PROXY environment variable to
your proxy server. Alternatively you may redefine iso_url to a local file,
set iso_checksum_type to none to disable checksuming, and remove
iso_checksum_url.

To use a proxy during the installation define the `KS_PROXY` variable in the
environment, as bellow:

```shell
export KS_PROXY="--proxy=\"${HTTP_PROXY}\""
```

## Building an image

You can easily build the image using the Makefile:

```shell
make
```

Alternatively you can manually run packer. Your current working directory must
be in packer-maas/centos6, where this file is located. Once in
packer-maas/centos6 you can generate an image with:

```shell
sudo packer init
sudo PACKER_LOG=1 packer build .
```

Note: centos6.pkr.hcl is configured to run Packer in headless mode. Only Packer
output will be seen. If you wish to see the installation output connect to the
VNC port given in the Packer output or change the value of headless to false in
centos6.pkr.hcl.

Installation is non-interactive.

## Uploading an image to MAAS

```shell
maas $PROFILE boot-resources create \
    name='centos/6-custom' title='CentOS 6 Custom' \
    architecture='amd64/generic' filetype='tgz' \
    content@=centos6.tar.gz
```

## Default Username

The default username is ```centos```

## Known limitations

### Storage

Only the flat storage layout is currently supported.
