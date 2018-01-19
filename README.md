# Hack on Envoy's GDB scripts

The [EnvoyProxy](https://github.com/envoyproxy/envoy) project has a neat ["run UT in GDB" script](https://github.com/envoyproxy/envoy/blob/master/bazel/README.md#running-a-single-bazel-test-under-gdb)

I like emacs and gud-gdb, so this is a hack on that.

Does following:
* opens emacs with split window:
  * gud-gdb
  * source code from test (hence you can't do things like //test/common/...)


From local clone of this repo:

```bash
 export ENVOY_SRC=/git/work/fdio/envoy
 ./bazel-test-gudgdb --package_path %workspace%:$ENVOY_SRC //test/common/http:async_client_impl_test --test_env=ENVOY_IP_TEST_VERSIONS=v4only -c dbg
```




## TODO
* gtags/ctags has an issue where tags can't be generated from the emacs instance launched from debugger. Could be perms (??) but generating tags prior to debug is way to go
