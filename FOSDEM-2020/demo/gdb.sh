#!/usr/bin/bash
export PS1="$ "
clear
set -x
gdb -q --nx --args /usr/bin/zip --help
