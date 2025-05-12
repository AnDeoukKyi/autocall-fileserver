#!/data/data/com.termux/files/usr/bin/bash

qemu-system-aarch64 -machine virt -m 4096 -cpu cortex-a57 \
-drive if=pflash,format=raw,readonly=on,file=$PREFIX/share/qemu/edk2-aarch64-code.fd \
-netdev user,id=n1,hostfwd=tcp::2222-:22 \
-device virtio-net,netdev=n1 \
-drive file=alpine.img,format=qcow2 \
-nographic