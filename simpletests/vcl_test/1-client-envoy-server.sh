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

if [[ -z "${VPPSRC}" || -z "${ENVOY_SRC}" || -z "${ENVOY_TOOLS}" ]]; then
    echo "VPPSRC=${VPPSRC}"
    echo "ENVOY_SRC=${ENVOY_SRC}"
    echo "ENVOY_TOOLS=${ENVOY_TOOLS}"
    echo "All need to be set"
    exit 1
fi

BIN_SERVER=$VPPSRC/build-root/build-vpp-native/vpp/.libs/vcl_test_server
BIN_CLIENT=$VPPSRC/build-root/build-vpp-native/vpp/.libs/vcl_test_client
BIN_VPP=$VPPSRC/build-root/install-vpp_debug-native/vpp/bin/vpp
BIN_ENVOY=$ENVOY_SRC/bazel-bin/source/exe/envoy-static -c $ENVOY_TOOLS/simpletests/socket_test/config/client-envoy-server.json &

SERVER=CLIENT=VPP=ENVOY=0

if [[ $# -eq 0 ]]; then
   SERVER=1
   CLIENT=1
   VPP=1
   ENVOY=1
   echo "Starting all"
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
			VPP=1
				;;
        --client)
            echo "start client"
            CLIENT=1
				;;
        --server)
            echo "start server"
            SERVER=1
				;;
        --envoy)
            echo "start envoy"
            ENVOY=1
				;;
        --*)
            echo "bad option $1"
            exit 1
             ;;
        *)
            echo "argument $1"
            exit 1
           ;;
    esac
    shift
done

#Kick off server
if [[ "${SERVER}" -eq 1 ]]; then
  if [[ -f "${BIN_SERVER}" ]]; then
    #$VPPSRC/build-root/build-vpp-native/vpp/.libs/vcl_test_server 22000 &
    #SERVER_PID=$!
    #sleep 2
    echo "running server"
  else
     echo "Asked for server but no executable"
     exit 1
  fi

fi


#Kick off envoy
if [[ "$ENVOY" -eq 1 ]]; then
  if [[ -f "${BIN_ENVOY}" ]]; then
#        ENVOY_PID=$!
#        sleep 2
    echo "starting envoy"
  else
     echo "Asked for Envoy but no executable"
     exit 1
  fi
fi

#Kick off client, get pid and wait
if [[ "$CLIENT" -eq 1 ]]; then
  if [[ -f "${BIN_CLIENT}" ]]; then
    echo "starting client"
  else
     echo "Asked for Envoy but no executable"
     exit 1
  fi
fi

exit 0

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
