#! /usr/bin/env bash
#
# 1-client-envoy-server.sh
#   -- script to run VPP+envoy tests.
#

# if [ $USER != "root" ] ; then
#     echo "Restarting script with sudo..."
#     sudo $0 ${*}
#     exit
# fi

export VCL_DEBUG=0
export VCL_APP_SCOPE_LOCAL=true
srvr_addr="127.0.0.1"

TEST_DIR="/git/work/fdio/envoyproxy/tools-envoy/simpletests/socket_test"


#Kick off server
/git/work/fdio/vpp/build-root/install-vpp-native/vpp/bin/sock_test_server 22000 &
SERVER_PID=$!
sleep 2
#Kick off envoy
$ENVOY_SRC/bazel-bin/source/exe/envoy-static -c $ENVOY_TOOLS/simpletests/socket_test/config/client-envoy-server.json &
ENVOY_PID=$!
sleep 2

#Kick off client, get pid and wait
/git/work/fdio/vpp/build-root/install-vpp-native/vpp/bin/sock_test_client -X -E "Hello!" $srvr_addr 22001 &
CLIENT_PID=$!

echo `jobs`

wait $CLIENT_PID
echo "*******************"
echo "******* Client done"
echo "*******************"
echo "**** Killing server"
echo "*******************"
kill ${SERVER_PID}
echo "*******************"
echo "***** Killing envoy"
echo "*******************"
kill ${ENVOY_PID}
