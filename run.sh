#!/bin/bash

OS_PATH="$(cd $(dirname "$0") > /dev/null 2>&1 && pwd)" 
echo "$OS_PATH"

cd ${OS_PATH}/src

make build
make burn
cd ${OS_PATH}
source ./dbg.sh
