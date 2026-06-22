USE uwunexus;

DROP TABLE IF EXISTS users;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    enrollment_number VARCHAR(50) NOT NULL,
    batch VARCHAR(50) NOT NULL,
    degree VARCHAR(50) NOT NULL,
    role ENUM('student', 'staff', 'clubadmin', 'superadmin') NOT NULL DEFAULT 'student',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Default superadmin account: admin@admin.com / admin
INSERT INTO users (full_name, email, password_hash, enrollment_number, batch, degree, role)
VALUES ('Super Admin', 'admin@admin.com', '$2y$12$QPn/EkO/dwBmGk27UZpNc.Udt1bbWT88owFNPWNFIX1F5fjdxKE9W', 'staff', 'staff', 'staff', 'superadmin');
