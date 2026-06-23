<?php
require 'db.php';
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(["success" => false, "message" => "Method not allowed"]);
    exit();
}

$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['id']) || !isset($data['user_id'])) {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "Missing required fields"]);
    exit();
}

$id = intval($data['id']);
$user_id = intval($data['user_id']);

try {
    $stmt = $pdo->prepare("SELECT role FROM users WHERE id = ?");
    $stmt->execute([$user_id]);
    $user = $stmt->fetch();

    if (!$user || !in_array($user['role'], ['superadmin'])) {
        http_response_code(403);
        echo json_encode(["success" => false, "message" => "Unauthorized"]);
        exit();
    }

    $stmt = $pdo->prepare("DELETE FROM info_hub_items WHERE id = ?");
    $stmt->execute([$id]);

    echo json_encode(["success" => true, "message" => "Item deleted successfully!"]);
} catch (\PDOException $e) {
    http_response_code(500);
    echo json_encode(["success" => false, "message" => "Database error: " . $e->getMessage()]);
}
?>
