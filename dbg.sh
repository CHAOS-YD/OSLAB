#!/bin/bash

export DISPLAY=192.168.153.1:0

cd $OS_PATH/bochs/bin && rm -rf hd60M.img.lock && ./bochs-dbg -q -f ./bochsrc-dbg.bxrc > /dev/null 2>&1
