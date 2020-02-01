#!/usr/bin/bash
export PS1="$ "
clear
set -x
lldb -x /usr/bin/zip -- --help
