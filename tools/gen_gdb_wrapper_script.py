#!/usr/bin/env python

# Support script for tools/bazel-test-gdb. This is passed to bazel test --run_under, and instead of
# running the test program it generates a wrapper program to allow for invoking gdb with the program
# in the bazel test environment. This is a workaround for the fact that --run_under does not attach
# stdin.

import os
import pipes
import string
import sys

GDB_RUNNER_SCRIPT = string.Template("""#!/usr/bin/env python

import os

fn = "${generated_path}.cmd"
f = open(fn,'w')
f.write("set directories /git/work/fdio/envoy \\n")

env = ${b64env}
for k, v in env.iteritems():
  os.environ[k] = v
  if not k.startswith('BASH_FUNC'):
    f.write("set environment "+str(k)+"="+str(v)+"\\n")


os.system("emacs --eval \\\"(progn (gud-gdb \\\\\\\"gdb -x ${generated_path}.cmd  --fullname ${binary} --args ${test_args}\\\\\\\") (find-file\\\\\\\"${source_path}\\\\\\\") (split-window-right) ) \\\"")
""")

if __name__ == '__main__':
  gdb = sys.argv[1]
  generated_path = sys.argv[2]
  test_args = sys.argv[3:]
  test_args[0] = os.path.abspath(test_args[0])
  test_name = test_args[0].split("/envoy/test")
  source_path = "/git/work/fdio/envoy/test" + test_name[-1] + ".cc"
  with open(generated_path, 'w') as f:
    f.write(
        GDB_RUNNER_SCRIPT.substitute(
            b64env=str(dict(os.environ)),
            generated_path=generated_path,
            source_path=source_path,
            binary=test_args[0],
            test_args=' '.join(pipes.quote(arg) for arg in test_args)))
  # To make bazel consider the test a failure we exit non-zero.
  print 'Test was not run, instead a gdb wrapper script was produced in %s' % generated_path
  sys.exit(1)
