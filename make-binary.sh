#!/bin/sh

sbcl --non-interactive --disable-debugger --eval '(ql:quickload "use-finder")' --eval '(sb-ext:disable-debugger)' --eval '(sb-ext:save-lisp-and-die "use-finder.bin" :toplevel #'"'"'use-finder::main :executable t)'
