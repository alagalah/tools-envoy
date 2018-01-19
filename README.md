# Hack on Envoy's GDB scripts

I like emacs and gud-gdb.


From local clone of this repo:

```bash
 export ENVOY_SRC=/git/work/fdio/envoy
 ./bazel-test-gudgdb --package_path %workspace%:$ENVOY_SRC //test/common/http:async_client_impl_test --test_env=ENVOY_IP_TEST_VERSIONS=v4only -c dbg
```

Does following:
* opens emacs with split window:
  * gud-gdb
  * source code from test (hence you can't do things like //test/common/...)


For debugging UT from github.com/alagalah/envoy

## TODO
* gtags/ctags has an issue where tags can't be generated from the emacs instance launched from debugger. Could be perms (??) but generating tags prior to debug is way to go
