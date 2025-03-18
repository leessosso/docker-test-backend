import express from 'express';
import pool from '../config/db';

export const healthRouter = express.Router();

// 기본 헬스체크 엔드포인트
healthRouter.get('/', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

// 상세 헬스체크 (데이터베이스 연결 상태 포함)
healthRouter.get('/detailed', async (req, res) => {
  try {
    // 데이터베이스 연결 상태 확인
    const connection = await pool.getConnection();
    connection.release();
    
    res.status(200).json({
      status: 'ok',
      timestamp: new Date().toISOString(),
      services: {
        database: 'connected'
      }
    });
  } catch (error) {
    console.error('헬스체크 중 데이터베이스 오류:', error);
    res.status(500).json({
      status: 'error',
      message: '데이터베이스 연결 실패',
      error: error instanceof Error ? error.message : String(error)
    });
  }
}); 