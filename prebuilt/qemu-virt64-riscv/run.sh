#!/bin/bash

# @author      zhouquan
# @file        run.sh
#
# Change Logs:
# Date           Author       Notes
# ------------   ----------   -----------------------------------------------
# 2023-01-12     zhouquan     initial version
#

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

qemu-system-riscv64 \
    -nographic \
    -machine virt \
    -m 256M \
    -kernel ${script_dir}/rtthread.bin \
    -drive if=none,file=${script_dir}/ext4.img,format=raw,id=blk0 \
    -device virtio-blk-device,drive=blk0,bus=virtio-mmio-bus.0 \
    -netdev user,id=tap0,hostfwd=tcp::8080-:80 \
    -device virtio-net-device,netdev=tap0,bus=virtio-mmio-bus.1 \
    -device virtio-serial-device \
    -chardev socket,host=127.0.0.1,port=43212,server=on,wait=off,telnet=on,id=console0 \
    -device virtserialport,chardev=console0
