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
    log "기존 .env 파일을 사용합니다."
    set -a
    source .env
    set +a
else
    log "경고: .env 파일이 없습니다. .env.example을 복사하여 사용합니다."
    cp .env.example .env
    set -a
    source .env
    set +a
fi

# 환경 변수 확인 (디버깅용)
log "환경 변수 확인:"
log "DOCKER_HUB_USERNAME: $DOCKER_HUB_USERNAME"
log "DB_HOST: $DB_HOST"
log "DB_PORT: $DB_PORT"
log "DB_USER: $DB_USER"
log "DB_NAME: $DB_NAME"
log "CORS_ORIGIN: $CORS_ORIGIN"

# DOCKER_HUB_USERNAME이 설정되지 않은 경우 기본값 설정
if [ -z "$DOCKER_HUB_USERNAME" ]; then
    log "DOCKER_HUB_USERNAME이 설정되지 않았습니다. 기본값 'default'를 사용합니다."
    export DOCKER_HUB_USERNAME="default"
fi

# 필수 환경 변수 확인
required_vars=(
    "DB_HOST"
    "DB_PORT"
    "DB_USER"
    "DB_PASSWORD"
    "DB_NAME"
    "CORS_ORIGIN"
)

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        log "경고: $var 환경 변수가 설정되지 않았습니다."
        
        # 기본값 설정
        case "$var" in
            "DB_HOST")
                export DB_HOST="localhost"
                log "$var 환경 변수를 'localhost'로 설정합니다."
                ;;
            "DB_PORT")
                export DB_PORT="5678"
                log "$var 환경 변수를 '5678'로 설정합니다."
                ;;
            "DB_USER")
                export DB_USER="root"
                log "$var 환경 변수를 'root'로 설정합니다."
                ;;
            "DB_PASSWORD")
                export DB_PASSWORD="your_password"
                log "$var 환경 변수를 'your_password'로 설정합니다."
                ;;
            "DB_NAME")
                export DB_NAME="franchise_db"
                log "$var 환경 변수를 'franchise_db'로 설정합니다."
                ;;
            "CORS_ORIGIN")
                export CORS_ORIGIN="http://localhost:9876"
                log "$var 환경 변수를 'http://localhost:9876'로 설정합니다."
                ;;
            *)
                log "오류: $var 환경 변수에 대한 기본값이 없습니다."
                exit 1
                ;;
        esac
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

# 네트워크 확인 및 생성
log "franchise-network 네트워크 확인 중..."
if ! docker network ls | grep -q "franchise-network"; then
    log "franchise-network 네트워크를 생성합니다..."
    docker network create franchise-network
else
    log "기존 franchise-network 네트워크를 사용합니다."
fi

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
log "중요: 백엔드가 먼저 배포되어야 프론트엔드가 정상 작동합니다."
log "이제 프론트엔드를 배포하세요: cd ../docker-test && ./deploy.sh" 