#!/bin/ash

# 🔧 서버 URL 확인
if [ -z "$SERVER_URL" ]; then
  echo "❌ SERVER_URL 환경변수가 없습니다. alpine-init.sh -s를 먼저 실행해주세요."
  exit 1
fi

# 🔧 model name/version 파싱
MODEL_NAME=$(jq -r .model_name stt-classification/app/config.json)
MODEL_VERSION=$(jq -r .model_version stt-classification/app/config.json)
IMAGE_NAME="${MODEL_NAME}_v${MODEL_VERSION}"

docker run -it --rm \
  -v $PWD/stt-classification/app:/app \
  -e APP_PORT=10000 \
  -p 10000:10000 \
  $IMAGE_NAME