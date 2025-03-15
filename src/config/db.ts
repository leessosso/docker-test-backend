import mysql from 'mysql2/promise';
import dotenv from 'dotenv';

dotenv.config();

// 호스트 문자열에서 호스트와 포트 분리
const parseHostAndPort = (hostString: string) => {
    // 호스트:포트 형식인지 확인
    if (hostString.includes(':')) {
        const [host, port] = hostString.split(':');
        return { host, port: parseInt(port, 10) };
    }
    return { host: hostString, port: undefined };
};

// 호스트 파싱 (이전 버전과의 호환성 유지)
const { host, port: parsedPort } = parseHostAndPort(process.env.DB_HOST || 'localhost');

// DB_PORT 환경 변수 또는 파싱된 포트 사용
const port = process.env.DB_PORT ? parseInt(process.env.DB_PORT, 10) : parsedPort;

const pool = mysql.createPool({
    host: host,
    port: port,
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME || 'franchise_db',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

export default pool; 