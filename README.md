# Hack on Envoy's GDB scripts

The [EnvoyProxy](https://github.com/envoyproxy/envoy) project has a neat ["run UT in GDB" script](https://github.com/envoyproxy/envoy/blob/master/bazel/README.md#running-a-single-bazel-test-under-gdb)

I like emacs and gud-gdb, so this is a hack on that.

Does following:
* DEFAULT: opens new emacs session with split window:
  * gud-gdb
  * source code from test (hence you can't do things like //test/common/...)
* OPTIONAL: with eval parameter:
  * expects an existing emacs server with socket in /tmp/emacs1000/server
  * uses emacsclient to open a buffer with elisp expressions
  * '''M-x eval-buffer''' will do DEFAULT actions and kill-buffer (terminating client)

From local clone of this repo:

```bash
 export ENVOY_SRC=/git/work/fdio/envoy
 ./bazel-test-gudgdb [eval] --package_path %workspace%:$ENVOY_SRC //test/common/http:async_client_impl_test --test_env=ENVOY_IP_TEST_VERSIONS=v4only -c dbg
```




## TODO
* gtags/ctags has an issue where tags can't be generated from the emacs instance launched from debugger. Could be perms (??) but generating tags prior to debug is way to go
  * this is moot when using "eval" option