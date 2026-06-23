<?php
require 'db.php';
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(["success" => false, "message" => "Method not allowed"]);
    exit();
}

$data = json_decode(file_get_contents("php://input"), true);

$required = ['category', 'title', 'description', 'user_id'];
foreach ($required as $field) {
    if (!isset($data[$field]) || empty(trim($data[$field]))) {
        http_response_code(400);
        echo json_encode(["success" => false, "message" => "Missing required field: $field"]);
        exit();
    }
}

$user_id = intval($data['user_id']);
$category = trim($data['category']);
$title = trim($data['title']);
$description = trim($data['description']);
$contact_info = isset($data['contact_info']) ? trim($data['contact_info']) : '';
$action_link = isset($data['action_link']) ? trim($data['action_link']) : '';
$action_text = isset($data['action_text']) ? trim($data['action_text']) : '';

try {
    // Basic superadmin check - verify user role
    $stmt = $pdo->prepare("SELECT role FROM users WHERE id = ?");
    $stmt->execute([$user_id]);
    $user = $stmt->fetch();

    if (!$user || !in_array($user['role'], ['superadmin'])) {
        http_response_code(403);
        echo json_encode(["success" => false, "message" => "Unauthorized. Only Superadmins can manage Info Hub."]);
        exit();
    }

    $stmt = $pdo->prepare("INSERT INTO info_hub_items (category, title, description, contact_info, action_link, action_text) VALUES (?, ?, ?, ?, ?, ?)");
    $stmt->execute([$category, $title, $description, $contact_info, $action_link, $action_text]);

    echo json_encode(["success" => true, "message" => "Item created successfully!", "id" => $pdo->lastInsertId()]);
} catch (\PDOException $e) {
    http_response_code(500);
    echo json_encode(["success" => false, "message" => "Database error: " . $e->getMessage()]);
}
?>
