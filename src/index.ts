import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { contactRouter } from './routes/contact';
import { healthRouter } from './routes/health';
import pool from './config/db';

dotenv.config();

const app = express();
const port = process.env.PORT || 5000;

// 미들웨어 설정
app.use(cors({
    origin: process.env.CORS_ORIGIN,
    credentials: true,
}));
app.use(express.json());

// 라우터 설정
app.use('/api/contact', contactRouter);
app.use('/api/health', healthRouter);

// 데이터베이스 연결 테스트
const testConnection = async () => {
    try {
        const connection = await pool.getConnection();
        console.log('MySQL 연결 성공');
        connection.release();
    } catch (error) {
        console.error('MySQL 연결 실패:', error);
        process.exit(1);
    }
};

testConnection();

// 서버 시작
app.listen(port, () => {
    console.log(`서버가 포트 ${port}에서 실행 중입니다.`);
}); 