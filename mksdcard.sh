if [ ! -f "sd.bin" ]; then
dd if=/dev/zero of=sd.bin bs=1024 count=65536
fi

mkfs.fat sd.bin
mcopy -i sd.bin root/bin/* ::
cp sd.bin ../kernel/bsp/qemu-vexpress-a9
