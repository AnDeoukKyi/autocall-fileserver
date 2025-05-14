#!/bin/ash

# 기본값: 환경변수에서 가져옴
SERVER_URL="${SERVER_URL}"
# 🔧 서버 URL 확인
if [ -z "$SERVER_URL" ]; then
  echo "❌ SERVER_URL 환경변수가 없습니다. alpine-init.sh -s를 먼저 실행해주세요."
  exit 1
fi

mkdir -p stt-classification/app/model

# BASE_URL과 파일 리스트 정의
BASE_URL="$SERVER_URL/files/app"
FILES="config.json main.py"

# 반복문 (ash 스타일)
for file in $FILES; do
  echo "📥 Downloading $file ..."
  wget -O "stt-classification/app/$file" "$BASE_URL/$file"
  chmod +x "stt-classification/app/$file"
  echo "✅ $file downloaded and made executable."
done

# 3. config.json 파싱해서 zip 파일 이름 결정
MODEL_NAME=$(jq -r .model_name stt-classification/app/config.json)
MODEL_VERSION=$(jq -r .model_version stt-classification/app/config.json)
IMAGE_NAME="${MODEL_NAME}_v${MODEL_VERSION}"

echo "🧩 모델 아카이브: $IMAGE_NAME.zip"

# 4. 모델 zip 다운로드
MODEL_ZIP_URL="$SERVER_URL/files/app/$IMAGE_NAME.zip"
wget -O "stt-classification/app/$IMAGE_NAME.zip" "$MODEL_ZIP_URL"
echo "✅ 모델 zip 파일 다운로드 완료: stt-classification/app/$IMAGE_NAME.zip"

mkdir -p stt-classification/app/model/$IMAGE_NAME

unzip -o "stt-classification/app/$IMAGE_NAME.zip" -d stt-classification/app/model/$IMAGE_NAME
rm "stt-classification/app/$IMAGE_NAME.zip"
echo "📦 모델 압축 해제 완료: stt-classification/app/model/"


wget -O "stt-classification/app/$IMAGE_NAME.tar" "$BASE_URL/$IMAGE_NAME.tar"
docker load -i $IMAGE_NAME.tar

echo "✅ 모든 설정이 완료되었습니다!"