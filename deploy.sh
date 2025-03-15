#!/bin/bash

# 환경 변수 파일이 없으면 예제 파일에서 복사
if [ ! -f .env ]; then
    cp .env.example .env
fi

# Docker 이미지 최신 버전 가져오기
docker pull $DOCKER_HUB_USERNAME/franchise-backend:latest

# Docker Compose로 서비스 재시작
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml up -d

# 사용하지 않는 이미지 정리
docker image prune -f 