#!/bin/ash

echo "📦 nano 설치 중..."
apk add nano pv grub unzip

echo "⚙️ /etc/inittab에서 ttyAMA0 항목 수정 중..."
sed -i 's|^ttyAMA0::.*|ttyAMA0::respawn:/bin/ash|' /etc/inittab

echo "⚙️ grub 설정 수정 중..."
sed -i 's/quiet/console=ttyAMA0/' /etc/default/grub

echo "📦 grub 설치 및 grub.cfg 생성 중..."
grub-mkconfig -o /boot/grub/grub.cfg
apk del grub


echo "🛠️ community repository 활성화 중..."
sed -i 's|#http://dl-cdn.alpinelinux.org/alpine/v3.21/community|http://dl-cdn.alpinelinux.org/alpine/v3.21/community|' /etc/apk/repositories

echo "🐳 docker 설치 및 설정 중..."
apk add docker
addgroup root docker
rc-update add docker boot
service docker start

echo "✅ 모든 설정이 완료되었습니다!"