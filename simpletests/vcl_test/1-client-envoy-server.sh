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

if [[ $# -eq 0 ]]; then
   SERVER=1
   CLIENT=1
   VPP=1
   ENVOY=1
fi

if [[ $# -gt 1 ]]; then
	echo "Too many args. Either:"
	echo "  <null>   : run all (envoy, client, server, vpp)"
	echo "  --client : just run vcl_test_client"
	echo "  --server : just run vcl_test_server"
	echo "  --vpp    : ju |server|vpp"
	exit 1
fi

while test $# -gt 0
do
    case "$1" in
        --vpp)
			echo "start vpp"
				;;
        --opt2) echo "option 2"
				;;
        --*) echo "bad option $1"
             ;;
        *) echo "argument $1"
           ;;
    esac
    shift
done



#Kick off server
/git/work/fdio/vpp/build-root/install-vpp_debug-native/vpp/bin/vcl_test_server 22000 &
SERVER_PID=$!
sleep 2
#Kick off envoy
$ENVOY_SRC/bazel-bin/source/exe/envoy-static -c $ENVOY_TOOLS/simpletests/socket_test/config/client-envoy-server.json &
ENVOY_PID=$!
sleep 2

#Kick off client, get pid and wait
/git/work/fdio/vpp/build-root/install-vpp_debug-native/vpp/bin/vcl_test_client -X -E "Hello!" $srvr_addr 22001 &
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
