CREATE DATABASE IF NOT EXISTS franchise_db;
USE franchise_db;

CREATE TABLE IF NOT EXISTS contacts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    region VARCHAR(100),
    budget VARCHAR(100),
    experience VARCHAR(100),
    message TEXT,
    privacy BOOLEAN NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
); 