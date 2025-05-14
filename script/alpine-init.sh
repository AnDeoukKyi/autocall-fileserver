#!/bin/ash

ssh-keygen -A
/usr/sbin/sshd

# 기본값: 환경변수에서 가져옴
SERVER_URL="${SERVER_URL}"

# 인자 파싱
while [ "$#" -gt 0 ]; do
  case "$1" in
    -s)
      shift
      SERVER_URL="$1"
      ;;
  esac
  shift
done

# 유효성 검사
if [ -z "$SERVER_URL" ]; then
  echo "❌ SERVER_URL이 없습니다. 환경변수로 설정하거나 -s 옵션으로 전달하세요."
  echo "   예: ./setup.sh -s http://12.34.56.78:8000"
  exit 1
fi

echo "🌐 SERVER_URL: $SERVER_URL"

apk add nano pv grub jq curl

echo "⚙️ /etc/inittab에서 ttyAMA0 항목 수정 중..."
sed -i 's|^ttyAMA0::.*|ttyAMA0::respawn:/bin/ash -l -c \"source /etc/profile; exec /bin/ash\"|' /etc/inittab

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

# /etc/profile에 등록 (덮어쓰기)
sed -i '/^export SERVER_URL=/d' /etc/profile
echo "export SERVER_URL=\"$SERVER_URL\"" >> /etc/profile

# 현재 세션에 적용
source /etc/profile

echo "✅ 모든 설정이 완료되었습니다!"