<?php
require 'db.php';
header('Content-Type: application/json');

try {
    $stmt = $pdo->query("SELECT id, name, icon FROM marketplace_categories ORDER BY id ASC");
    $categories = $stmt->fetchAll();
    
    echo json_encode(["success" => true, "categories" => $categories]);
} catch (\PDOException $e) {
    http_response_code(500);
    echo json_encode(["success" => false, "message" => "Database error: " . $e->getMessage()]);
}
?>
