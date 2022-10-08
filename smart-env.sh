#!/bin/bash

# usage:
# source smart-env.sh [arch]
# example: source smart-env.sh          # arm
# example: source smart-env.sh aarch64  # aarch64

# supported arch list
supported_arch="arm aarch64 riscv64 i386"

def_arch="unknown" 

SHELL_FOLDER=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)

# find arch in arch list
if [ -z $1 ]
then
    def_arch="arm" # default arch is arm
else
    for arch in $supported_arch
    do
        if [ $arch = $1 ]
        then
            def_arch=$arch
            break
        fi
    done
fi

# set env
case $def_arch in 
    "arm")
        export RTT_CC=gcc
        export RTT_EXEC_PATH=$(pwd)/tools/gnu_gcc/arm-linux-musleabi_for_x86_64-pc-linux-gnu/bin
        export RTT_CC_PREFIX=arm-linux-musleabi-
        cp $SHELL_FOLDER/configs/def_config_arm $SHELL_FOLDER/.config
        ;;
    "aarch64")
        export RTT_CC=gcc
        export RTT_EXEC_PATH=$(pwd)/tools/gnu_gcc/aarch64-linux-musleabi_for_x86_64-pc-linux-gnu/bin
        export RTT_CC_PREFIX=aarch64-linux-musleabi-
        cp $SHELL_FOLDER/configs/def_config_aarch64 $SHELL_FOLDER/.config
        ;;
    "riscv64")
        export RTT_CC=gcc
        export RTT_EXEC_PATH=$(pwd)/tools/gnu_gcc/riscv64-linux-musleabi_for_x86_64-pc-linux-gnu/bin
        export RTT_CC_PREFIX=riscv64-unknown-linux-musl-
        cp $SHELL_FOLDER/configs/def_config_riscv64 $SHELL_FOLDER/.config
        ;;
    "i386")
        export RTT_CC=gcc
        export RTT_EXEC_PATH=$(pwd)/tools/gnu_gcc/i386-linux-musleabi_for_x86_64-pc-linux-gnu/bin
        export RTT_CC_PREFIX=i386-unknown-linux-musl-
        ;;
    *)  echo "unknown arch!"
        return 1
esac

# export RTT_EXEC_PATH
export PATH=$PATH:$RTT_EXEC_PATH

echo "Arch      => ${def_arch}"
echo "CC        => ${RTT_CC}"
echo "PREFIX    => ${RTT_CC_PREFIX}"
echo "EXEC_PATH => ${RTT_EXEC_PATH}"