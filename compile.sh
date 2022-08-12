#!/bin/sh
set -e
cd "$(dirname "$0")"

if [ "$1" = -w ]; then
    exec watchexec -rcw moon -e moon ./compile.sh
fi

rm -rfv lua
cd moon
moonc -t ../lua .