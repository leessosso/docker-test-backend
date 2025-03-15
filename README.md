# docker-test-backend

Docker 기반의 Express + TypeScript 백엔드 서버

## 기술 스택

- Node.js
- Express
- TypeScript
- MySQL
- Docker
- GitHub Actions

## 개발 환경 설정

1. 의존성 설치
```bash
npm install
```

2. 환경 변수 설정
```bash
cp .env.example .env
# .env 파일을 수정하여 실제 데이터베이스 정보 입력
```

3. 개발 서버 실행
```bash
npm run dev
```

4. 빌드
```bash
npm run build
```

## Docker 실행

```bash
docker build -t docker-test-backend .
docker run -p 3000:3000 --network host docker-test-backend
```

## GitHub Actions 설정

GitHub Actions를 통한 자동 배포를 위해 다음 시크릿을 설정해야 합니다:

- `SERVER_HOST`: 서버 호스트 주소
- `SERVER_USERNAME`: SSH 접속용 사용자 이름
- `SSH_PRIVATE_KEY`: SSH 개인키
- `DB_HOST`: 데이터베이스 호스트
- `DB_USER`: 데이터베이스 사용자
- `DB_PASSWORD`: 데이터베이스 비밀번호
- `DB_NAME`: 데이터베이스 이름
