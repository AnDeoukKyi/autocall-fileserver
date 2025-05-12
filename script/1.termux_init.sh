#!/data/data/com.termux/files/usr/bin/bash

# 인자 확인
if [ $# -eq 0 ]; then
    echo "❗ 사용법: $0 [termux <FILE_SERVER_URL> | install | grub | run]"
    exit 1
fi

case "$1" in
  termux)
    if [ -z "$2" ]; then
        echo "❗ termux 모드일 경우 파일 서버 주소가 필요합니다."
        echo "예: $0 termux http://xxx.xxx.xxx.xxx:oooo"
        exit 1
    fi

    echo "📂 Termux 스토리지 설정"
    if [ ! -d "$HOME/storage" ]; then
      echo "📂 Termux storage not initialized. Running termux-setup-storage..."
      termux-setup-storage
      sleep 2
    else
      echo "✅ Termux storage already initialized. Skipping termux-setup-storage."
    fi

    echo "📦 패키지 설치 중..."
    pkg update -y && pkg upgrade -y
    pkg install -y openssh nano root-repo x11-repo

	#스크립트 다운로드
    BASE_URL="$2/files/script"
    FILES=("2.alpine-install.sh" "3.alpine-grub.sh" "4.alpine-run.sh")

    for file in "${FILES[@]}"; do
      echo "📥 Downloading $file ..."
      wget -O "$file" "$BASE_URL/$file"
      chmod +x "$file"
      echo "✅ $file downloaded and made executable."
    done

	#파일 다운로드
	FILE_URL="$2/files/file"
	ISO_FILE="alpine-virt-3.21.3-aarch64.iso"

	echo "📥 Downloading ISO image $ISO_FILE from $FILE_URL ..."
	wget -O "alpine.iso" "$FILE_URL/$ISO_FILE" || {
	  echo "❌ ISO 다운로드 실패!"
	  exit 1
	}
	echo "✅ ISO image $ISO_FILE downloaded."


    echo "👤 현재 사용자:"
    whoami

    echo "🔐 비밀번호 설정 (로그인용)"
    passwd

    echo "🚀 SSH 서버 시작"
    sshd
    ;;

  install)
    ./2.alpine-install.sh
    ;;

  grub)
    ./3.alpine-grub.sh
    ;;

  run)
    ./4.alpine-run.sh
    ;;

  *)
    echo "❗ 알 수 없는 명령어: $1"
    echo "사용 가능한 명령어: termux <URL>, install, grub, run"
    exit 1
    ;;
esac
