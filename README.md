# Docker Test Backend

Express와 TypeScript를 사용한 백엔드 API 서버입니다.

## 기술 스택

- Node.js
- Express 4.18
- TypeScript 5.7
- MySQL 3.2
- Docker
- GitHub Actions

## 주요 의존성

- cors 2.8
- dotenv 16.0
- mysql2 3.2
- Jest 29.5 (테스트)

## 개발 환경 설정

### 필수 요구사항

- Node.js 18.x 이상
- npm 8.x 이상
- MySQL 8.x
- Docker 및 Docker Compose (선택사항)

### 로컬 개발 환경 설정

```bash
# 의존성 설치
npm install

# 환경 변수 설정
cp .env.example .env
# .env 파일을 수정하여 실제 데이터베이스 정보 입력

# 개발 서버 실행
npm run dev
```

## 스크립트

- `npm start`: 프로덕션 모드로 서버 실행
- `npm run dev`: 개발 모드로 서버 실행 (자동 재시작)
- `npm run build`: TypeScript 컴파일
- `npm run lint`: ESLint 검사
- `npm run lint:fix`: ESLint 검사 및 자동 수정
- `npm test`: Jest 테스트 실행
- `npm run typecheck`: TypeScript 타입 체크

## Docker 실행

### 로컬 개발 환경

```bash
# Docker 이미지 빌드
docker build -t docker-test-backend .

# Docker Compose로 실행 (MySQL 포함)
docker-compose up -d
```

### 프로덕션 환경

```bash
# 프로덕션용 Docker Compose 실행
docker-compose -f docker-compose.prod.yml up -d
```

## CI/CD 파이프라인

GitHub Actions를 통한 자동 배포가 구성되어 있습니다.

### GitHub Secrets 설정

다음 시크릿들을 GitHub 저장소 설정에 추가해야 합니다:

- `SERVER_HOST`: 서버 호스트 주소
- `SERVER_USERNAME`: SSH 접속용 사용자 이름
- `SSH_PRIVATE_KEY`: SSH 개인키
- `DB_HOST`: 데이터베이스 호스트
- `DB_USER`: 데이터베이스 사용자
- `DB_PASSWORD`: 데이터베이스 비밀번호
- `DB_NAME`: 데이터베이스 이름

### 배포 프로세스

1. main 브랜치에 push 또는 PR merge 시 자동으로 배포가 시작됩니다.
2. TypeScript 타입 체크 및 린트 검사를 실행합니다.
3. 단위 테스트를 실행합니다.
4. Docker 이미지를 빌드하고 배포 서버에 전송합니다.
5. 배포 서버에서 새 버전을 실행합니다.

## 개발 가이드

### 디렉토리 구조

```
src/
├── config/        # 환경 설정
├── controllers/   # 라우트 컨트롤러
├── middleware/    # Express 미들웨어
├── models/        # 데이터베이스 모델
├── routes/        # API 라우트 정의
├── services/      # 비즈니스 로직
├── types/         # TypeScript 타입 정의
└── utils/         # 유틸리티 함수
```

### API 문서

API 엔드포인트에 대한 자세한 문서는 추후 Swagger/OpenAPI를 통해 제공될 예정입니다.

## 문제 해결

### 데이터베이스 연결 문제

1. `.env` 파일의 데이터베이스 설정이 올바른지 확인
2. MySQL 서버가 실행 중인지 확인
3. 방화벽 설정 확인

### Docker 관련 문제

Windows WSL2 사용 시 포트 포워딩 문제가 발생할 수 있습니다. 자세한 해결 방법은 프론트엔드 프로젝트의 `wsl2-port-forwarding-guide.md`를 참고하세요.
