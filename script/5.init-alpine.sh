#!/bin/ash

# 인자 확인
if [ -z "$1" ]; then
  echo "❗ 사용법: $0 <FILE_SERVER_URL>"
  echo "예: $0 http://xxx.xxx.xxx.xxx:oooo"
  exit 1
fi

SERVER="$1"

echo "📦 nano 설치 중..."
apk add nano pv grub

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

echo "📥 Docker 이미지 다운로드 중..."
wget -O koelectra.tar "$SERVER/files/file/koelectra.tar"

echo "📦 Docker 이미지 로드 중..."
pv koelectra.tar | docker load

echo "📥 app/main.py 다운로드 중..."
mkdir -p app
wget -O app/main.py "$SERVER/files/app/main.py"

echo "✅ 모든 설정이 완료되었습니다!"
