<?php
require 'db.php';
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(["success" => false, "message" => "Method not allowed"]);
    exit();
}

$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['requester_id']) || !isset($data['target_id']) || !isset($data['new_role'])) {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "Missing fields"]);
    exit();
}

$requester_id = intval($data['requester_id']);
$target_id = intval($data['target_id']);
$new_role = $data['new_role'];

$allowed_roles = ['student', 'staff', 'clubadmin', 'superadmin'];
if (!in_array($new_role, $allowed_roles)) {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "Invalid role"]);
    exit();
}

try {
    // Only superadmin can update roles
    $stmt = $pdo->prepare("SELECT role FROM users WHERE id = ?");
    $stmt->execute([$requester_id]);
    $requester = $stmt->fetch();

    if (!$requester || $requester['role'] !== 'superadmin') {
        http_response_code(403);
        echo json_encode(["success" => false, "message" => "Only superadmins can change roles"]);
        exit();
    }

    // Prevent changing own role
    if ($requester_id === $target_id) {
        http_response_code(400);
        echo json_encode(["success" => false, "message" => "You cannot change your own role"]);
        exit();
    }

    $stmt = $pdo->prepare("UPDATE users SET role = ? WHERE id = ?");
    $stmt->execute([$new_role, $target_id]);

    echo json_encode(["success" => true, "message" => "Role updated successfully"]);
} catch (\PDOException $e) {
    http_response_code(500);
    echo json_encode(["success" => false, "message" => "Database error"]);
}
?>
