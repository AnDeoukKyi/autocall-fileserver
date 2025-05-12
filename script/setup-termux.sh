#!/data/data/com.termux/files/usr/bin/bash

# 1. SERVER_URL 처리
SERVER_URL="$1"
if [ -z "$SERVER_URL" ]; then
  echo "❌ SERVER_URL 인자가 필요합니다. 예: ./setup-termux.sh 12.12.12.12:8000"
  exit 1
fi

echo "🌐 SERVER_URL: $SERVER_URL"

# ~/.bashrc 수정: 기존 SERVER_URL 제거 후 추가
sed -i '/^export SERVER_URL=/d' ~/.bashrc
echo "export SERVER_URL='$SERVER_URL'" >> ~/.bashrc
echo "✅ SERVER_URL이 ~/.bashrc에 저장되었습니다."

# 2. Termux storage 설정
echo "📂 Termux 스토리지 설정"
if [ ! -d "$HOME/storage" ]; then
  echo "📂 Termux storage not initialized. Running termux-setup-storage..."
  termux-setup-storage
  sleep 2
else
  echo "✅ Termux storage already initialized. Skipping termux-setup-storage."
fi

# 3. 패키지 설치
echo "📦 패키지 설치 중..."
pkg update -y && pkg upgrade -y
pkg install -y openssh nano root-repo x11-repo

# 4. 스크립트 및 ISO 다운로드
echo "📥 스크립트 및 ISO 다운로드 시작"

BASE_URL="$SERVER_URL/files/script"
FILES=("2.alpine-install.sh" "3.alpine-grub.sh" "4.alpine-run.sh")

for file in "${FILES[@]}"; do
  echo "📥 Downloading $file ..."
  wget -O "$file" "$BASE_URL/$file"
  chmod +x "$file"
  echo "✅ $file downloaded and made executable."
done

# ISO 파일 다운로드
FILE_URL="$SERVER_URL/files/file"
ISO_FILE="alpine.iso"

echo "📥 Downloading ISO image $ISO_FILE from $FILE_URL ..."
wget -O "alpine.iso" "$FILE_URL/$ISO_FILE" || {
  echo "❌ ISO 다운로드 실패!"
  exit 1
}
echo "✅ ISO image $ISO_FILE downloaded."

# 5. 사용자 및 SSH 설정
echo "👤 현재 사용자:"
whoami

echo "🔐 비밀번호를 'mill'로 설정합니다"
echo -e "mill\nmill" | passwd

echo "🚀 SSH 서버 시작"
sshd

echo "✅ 모든 작업 완료"
