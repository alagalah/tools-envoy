* Hack on Envoy's GDB scripts

I like emacs and gud-gdb.

Some opinionated pathing hardcoded for where I keep things.

Easy enough to fix.

From this repo:

```bash
 export FDIO=/git/work/fdio/envoy 
 ./tools/bazel-test-gdb --package_path %workspace%:$FDIO/envoy //test/common/http:async_client_impl_test --test_env=ENVOY_IP_TEST_VERSIONS=v4only -c dbg
```

Does following:
* opens emacs with split window:
** gud-gdb
** source code from test (hence you can't do things like //test/common/...)


For debugging UT from github.com/alagalah/envoy

TODO:
* "set directories" in .py needs to have the ~/.cache/bazel/.../<UUID> added in order to step through source
** temporarily you can, for example:
```
(gdb) directory  /home/alagalah/.cache/bazel/_bazel_alagalah/b3ac823edb50659b90c8bc3c2a07ed24
```
* gtags/ctags has an issue where tags can't be generated due to some perms issue. Ensure gtags up to date prior to running UT
* get rid of hard coded path references to my local repo. Only did this because all the nested / escaping was making me crazy
