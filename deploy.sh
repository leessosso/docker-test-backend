#!/bin/bash

# 스크립트 실행 오류 시 중단
set -e

# 스크립트 디렉토리로 이동
cd "$(dirname "$0")"

# 로그 함수
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Docker 데몬 실행 확인
if ! docker info > /dev/null 2>&1; then
    log "Docker 데몬이 실행되지 않았습니다. 시작합니다..."
    sudo service docker start
    sleep 3
fi

# 환경 변수 로드
if [ -f .env ]; then
    set -a
    source .env
    set +a
    log "환경 변수를 로드했습니다."
else
    log "경고: .env 파일이 없습니다. .env.production을 복사하여 사용합니다."
    cp .env.production .env
    set -a
    source .env
    set +a
fi

# 필수 환경 변수 확인
required_vars=(
    "DOCKER_HUB_USERNAME"
    "DB_HOST"
    "DB_USER"
    "DB_PASSWORD"
    "DB_NAME"
    "CORS_ORIGIN"
)

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        log "오류: $var 환경 변수가 설정되지 않았습니다."
        exit 1
    fi
done

# docker-compose 명령어 확인
if ! command -v docker-compose &> /dev/null; then
    if command -v docker compose &> /dev/null; then
        alias docker-compose='docker compose'
    else
        log "오류: docker-compose 명령어를 찾을 수 없습니다."
        exit 1
    fi
fi

# 최신 이미지 가져오기
log "최신 Docker 이미지를 가져오는 중..."
docker pull $DOCKER_HUB_USERNAME/franchise-backend:latest || {
    log "오류: Docker 이미지를 가져오는데 실패했습니다."
    exit 1
}

# 기존 컨테이너 중지 및 제거
log "기존 컨테이너 정리 중..."
docker compose -f docker-compose.prod.yml down || true

# 새 컨테이너 시작
log "새 컨테이너 시작 중..."
docker compose -f docker-compose.prod.yml up -d || {
    log "오류: 컨테이너 시작에 실패했습니다."
    exit 1
}

# 컨테이너 상태 확인
log "컨테이너 상태 확인 중..."
sleep 5
if [ "$(docker ps -q -f name=franchise-backend)" ]; then
    log "컨테이너가 정상적으로 실행 중입니다."
else
    log "오류: 컨테이너가 실행되지 않았습니다."
    docker logs franchise-backend
    exit 1
fi

# 사용하지 않는 이미지 정리
log "사용하지 않는 이미지 정리 중..."
docker image prune -af --filter "until=24h"

log "백엔드 배포가 완료되었습니다!" 