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

env = ${b64env}
env_lines = []
for k, v in env.iteritems():
  os.environ[k] = v
  if not k.startswith('BASH_FUNC'):
    env_lines.append("set environment "+str(k)+"="+str(v)+"\\n")
  if k == 'RUNFILES_DIR':
    dbg_dir=v.split("execroot")
    env_lines.append("set directories :${project_path}:"+str(dbg_dir[0])+"\\n")


f.writelines(env_lines)
f.close()

if '${gdb}' == 'gdb':
  os.system("emacs --eval \\\"(progn (gud-gdb \\\\\\\"gdb -x ${generated_path}.cmd  --fullname ${binary} --args ${test_args}\\\\\\\") (find-file \\\\\\\"${source_path}\\\\\\\") (split-window-right) ) \\\"")
else:
  evalfn = "${generated_path}.emacseval"
  eval_lines = []
  f = open (evalfn, 'w')
  eval_lines.append('''(gud-gdb \"gdb -x ${generated_path}.cmd  --fullname ${binary} --args ${test_args}\") \n''')
  eval_lines.append('''(find-file "${source_path}\") \n''')
  buffer=fn.split('/tmp/')
  eval_buffer=evalfn.split('/tmp/')
  eval_lines.append('''(switch-to-buffer-other-window "*gud-'''+buffer[-1]+'''*") \n''')
  eval_lines.append('''(remove-hook 'kill-buffer-query-functions 'server-kill-buffer-query-function)''')
  eval_lines.append('''(kill-buffer "'''+eval_buffer[-1]+'''")''')
  f.writelines(eval_lines)
  f.close()
  print "Running emacsclient -s /tmp/emacs1000/server "+evalfn
  print "Expecting emacs running with start-server"
  os.system("emacsclient -s /tmp/emacs1000/server %s" % evalfn)
""")


if __name__ == '__main__':
  project_path = sys.argv[1]
  gdb = sys.argv[2]
  generated_path = sys.argv[3]
  test_args = sys.argv[4:]
  test_args[0] = os.path.abspath(test_args[0])
  test_name = test_args[0].split("/envoy/test")
  source_path =  str(project_path) + "/test" + test_name[-1] + ".cc"
  with open(generated_path, 'w') as f:
    f.write(
        GDB_RUNNER_SCRIPT.substitute(
            b64env=str(dict(os.environ)),
            generated_path=generated_path,
            gdb=gdb,
            project_path=project_path,
            source_path=source_path,
            binary=test_args[0],
            test_args=' '.join(pipes.quote(arg) for arg in test_args)))
  # To make bazel consider the test a failure we exit non-zero.
  print 'Test was not run, instead a gdb wrapper script was produced in %s' % generated_path
  sys.exit(1)
