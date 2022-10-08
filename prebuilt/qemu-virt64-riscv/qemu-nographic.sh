#!/bin/bash
SHELL_FOLDER=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)

if [ ! -f ${SHELL_FOLDER}/"sd.bin" ]; then
qemu-img create -f raw ${SHELL_FOLDER}/sd.bin 64M
fi

qemu-system-riscv64 -nographic -machine virt -m 256M -kernel ${SHELL_FOLDER}/rtthread.bin \
-drive if=none,file=${SHELL_FOLDER}/sd.bin,format=raw,id=blk0 -device virtio-blk-device,drive=blk0,bus=virtio-mmio-bus.0 \
-netdev user,id=tap0 -device virtio-net-device,netdev=tap0,bus=virtio-mmio-bus.1 \
-device virtio-serial-device -chardev socket,host=127.0.0.1,port=4321,server=on,wait=off,telnet=on,id=console0 -device virtserialport,chardev=console0
