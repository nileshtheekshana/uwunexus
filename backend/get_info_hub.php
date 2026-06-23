<?php
require 'db.php';
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(["success" => false, "message" => "Method not allowed"]);
    exit();
}

try {
    $stmt = $pdo->query("SELECT * FROM info_hub_items ORDER BY category ASC, title ASC");
    $items = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode(["success" => true, "items" => $items]);
} catch (\PDOException $e) {
    http_response_code(500);
    echo json_encode(["success" => false, "message" => "Database error: " . $e->getMessage()]);
}
?>
