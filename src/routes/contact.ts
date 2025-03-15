import express from 'express';
import pool from '../config/db';

const router = express.Router();

router.post('/', async (req, res) => {
    try {
        const { name, email, phone, region, budget, experience, message, privacy } = req.body;

        const [result] = await pool.execute(
            'INSERT INTO contacts (name, email, phone, region, budget, experience, message, privacy) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
            [name, email, phone, region, budget, experience, message, privacy]
        );

        res.status(201).json({
            success: true,
            message: '문의가 성공적으로 접수되었습니다.',
            data: { id: (result as any).insertId, ...req.body }
        });
    } catch (error) {
        console.error('문의 접수 중 오류 발생:', error);
        res.status(500).json({
            success: false,
            message: '문의 접수 중 오류가 발생했습니다.',
            error: error instanceof Error ? error.message : '알 수 없는 오류'
        });
    }
});

export const contactRouter = router; 