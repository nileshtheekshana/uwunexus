<?php
require 'db.php';

try {
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS info_hub_items (
            id INT AUTO_INCREMENT PRIMARY KEY,
            category ENUM('procedure', 'hotline', 'contact') NOT NULL,
            title VARCHAR(255) NOT NULL,
            description TEXT NOT NULL,
            contact_info VARCHAR(255) DEFAULT '',
            action_link VARCHAR(255) DEFAULT '',
            action_text VARCHAR(100) DEFAULT '',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
    ");
    echo "info_hub_items table created.\n";

} catch (\PDOException $e) {
    echo "Error creating tables: " . $e->getMessage() . "\n";
}
?>
