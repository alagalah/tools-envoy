* Hack on Envoy's GDB scripts

I like emacs and gud-gdb.

Some opinionated pathing hardcoded for where I keep things.

Easy enough to fix.

From this repo:


 export FDIO=/git/work/fdio/envoy 
 ./tools/bazel-test-gdb --package_path %workspace%:$FDIO/envoy //test/common/http:async_client_impl_test --test_env=ENVOY_IP_TEST_VERSIONS=v4only -c dbg

For debugging UT from github.com/alagalah/envoy
