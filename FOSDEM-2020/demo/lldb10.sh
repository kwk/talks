#!/usr/bin/bash
export PS1="$ "
clear
set -x
~/llvm-builds/current-build/bin/lldb -x /usr/bin/zip -- --help
