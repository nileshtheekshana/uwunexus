<?php
require 'db.php';

try {
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS marketplace_categories (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(100) NOT NULL UNIQUE,
            icon VARCHAR(50) DEFAULT 'Tag'
        );

        CREATE TABLE IF NOT EXISTS marketplace_items (
            id INT AUTO_INCREMENT PRIMARY KEY,
            title VARCHAR(255) NOT NULL,
            description TEXT NOT NULL,
            price DECIMAL(10, 2) NOT NULL,
            condition_state VARCHAR(50) NOT NULL,
            category_id INT NOT NULL,
            seller_id INT NOT NULL,
            status ENUM('active', 'sold', 'hidden') DEFAULT 'active',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (category_id) REFERENCES marketplace_categories(id) ON DELETE RESTRICT,
            FOREIGN KEY (seller_id) REFERENCES users(id) ON DELETE CASCADE
        );

        CREATE TABLE IF NOT EXISTS marketplace_images (
            id INT AUTO_INCREMENT PRIMARY KEY,
            item_id INT NOT NULL,
            image_url VARCHAR(500) NOT NULL,
            FOREIGN KEY (item_id) REFERENCES marketplace_items(id) ON DELETE CASCADE
        );

        INSERT IGNORE INTO marketplace_categories (name, icon) VALUES 
            ('Textbooks & Notes', 'Book'),
            ('Electronics & Gadgets', 'Laptop'),
            ('Stationery & Tools', 'PenTool'),
            ('Hostel Essentials', 'Bed'),
            ('Other', 'Package');
    ");
    echo "Tables created successfully.\n";
} catch (\PDOException $e) {
    echo "Error creating tables: " . $e->getMessage() . "\n";
}
?>
