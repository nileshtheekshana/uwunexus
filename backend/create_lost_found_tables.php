<?php
require 'db.php';

try {
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS lost_found_items (
            id INT AUTO_INCREMENT PRIMARY KEY,
            title VARCHAR(255) NOT NULL,
            description TEXT NOT NULL,
            location VARCHAR(255) NOT NULL,
            time_date VARCHAR(255) NOT NULL,
            type ENUM('Lost', 'Found') NOT NULL,
            status ENUM('active', 'resolved') DEFAULT 'active',
            contact_number VARCHAR(20) NOT NULL,
            contact_email VARCHAR(100) DEFAULT '',
            user_id INT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );
    ");
    echo "lost_found_items table created.\n";

    $pdo->exec("
        CREATE TABLE IF NOT EXISTS lost_found_images (
            id INT AUTO_INCREMENT PRIMARY KEY,
            item_id INT NOT NULL,
            image_url VARCHAR(255) NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (item_id) REFERENCES lost_found_items(id) ON DELETE CASCADE
        );
    ");
    echo "lost_found_images table created.\n";

} catch (\PDOException $e) {
    echo "Error creating tables: " . $e->getMessage() . "\n";
}
?>
