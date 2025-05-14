#!/data/data/com.termux/files/usr/bin/bash

CORES="$1"
if [ -z "$CORES" ]; then
  CORES=2
  echo "ℹ️ 코어 개수가 지정되지 않아 기본값 2를 사용합니다."
else
  echo "🧠 사용할 코어 수: $CORES"
fi

qemu-system-aarch64 -machine virt -m 4096 -cpu cortex-a57 -smp "$CORES" \
-drive if=pflash,format=raw,readonly=on,file=$PREFIX/share/qemu/edk2-aarch64-code.fd \
-netdev user,id=n1,hostfwd=tcp::2222-:22,hostfwd=tcp::10000-:10000 \
-device virtio-net,netdev=n1 \
-drive file=alpine.img,format=qcow2 \
-nographic