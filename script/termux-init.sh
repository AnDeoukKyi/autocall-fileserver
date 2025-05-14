#!/data/data/com.termux/files/usr/bin/bash

# 1. 인자 파싱: -s 옵션 우선, 없으면 환경변수 SERVER_URL 사용
SERVER_URL="$SERVER_URL"  # 기본값: 환경변수

while [ "$#" -gt 0 ]; do
  case "$1" in
    -s)
      shift
      SERVER_URL="$1"
      ;;
    *)
      echo "❗ 알 수 없는 옵션: $1"
      echo "사용법: ./termux-setup.sh [-s ip:port]"
      exit 1
      ;;
  esac
  shift
done

# 2. 유효성 검사
if [ -z "$SERVER_URL" ]; then
  echo "❌ SERVER_URL이 없습니다. 환경변수로 설정하거나 -s 옵션으로 전달하세요."
  echo "예: ./termux-setup.sh -s 12.12.12.12:8000"
  exit 1
fi

echo "🌐 SERVER_URL: $SERVER_URL"

# 3. ~/.bashrc 수정: 기존 SERVER_URL 제거 후 추가
sed -i '/^export SERVER_URL=/d' ~/.bashrc
echo "export SERVER_URL='$SERVER_URL'" >> ~/.bashrc
echo "✅ SERVER_URL이 ~/.bashrc에 저장되었습니다."

source ~/.bashrc

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
FILES=("termux-install-alpine.sh" "termux-run-alpine.sh")

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
