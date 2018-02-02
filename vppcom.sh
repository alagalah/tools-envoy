#!/bin/bash

#### DO NOT MERGE ME #######
#### This file belongs in $ENVOY_SRC/ci/build_container/build_recipes/vppcom.sh
#### This version should not be merged, but it allows for using local repo instead of git

set -e

#git clone https://gerrit.fd.io/r/vpp
cp -r /git/work/fdio/vpp -T ./vpp
BASEDIR=$(pwd)
ARTIFACT_BASE=${BASEDIR}/vpp/build-root/install-vpp_debug-native/vpp

cd vpp
make vpp_configure_args_vpp="--disable-dpdk-plugin --disable-pppoe-plugin --disable-nat-plugin --disable-lb-plugin --disable-japi --disable-vapi --disable-vom --disable-stn-plugin" bootstrap build

cd $ARTIFACT_BASE/include

find ./svm -name '*.h' | cpio -updm "$THIRDPARTY_BUILD"/include
find ./vlibmemory -name '*.h' | cpio -updm "$THIRDPARTY_BUILD"/include
find ./vppinfra -name '*.h' | cpio -updm "$THIRDPARTY_BUILD"/include
find ./vcl -name '*.h' | cpio -updm "$THIRDPARTY_BUILD"/include

cd $ARTIFACT_BASE/lib64
cp *.a "$THIRDPARTY_BUILD"/lib
