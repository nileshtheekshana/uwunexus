<?php
require 'db.php';
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(["success" => false, "message" => "Method not allowed"]);
    exit();
}

$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['item_id']) || !isset($data['user_id'])) {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "Missing item_id or user_id"]);
    exit();
}

$item_id = intval($data['item_id']);
$user_id = intval($data['user_id']);
$action = isset($data['action']) ? $data['action'] : 'delete'; // 'delete', 'hide', 'approve', 'reject'

try {
    // Verify admin
    $stmt = $pdo->prepare("SELECT role FROM users WHERE id = ?");
    $stmt->execute([$user_id]);
    $user = $stmt->fetch();

    if (!$user || ($user['role'] !== 'superadmin' && $user['role'] !== 'clubadmin')) {
        http_response_code(403);
        echo json_encode(["success" => false, "message" => "Unauthorized"]);
        exit();
    }

    if ($action === 'hide') {
        $stmt = $pdo->prepare("UPDATE marketplace_items SET status = 'hidden' WHERE id = ?");
        $stmt->execute([$item_id]);
        echo json_encode(["success" => true, "message" => "Item hidden successfully"]);
    } elseif ($action === 'approve') {
        $stmt = $pdo->prepare("UPDATE marketplace_items SET status = 'active' WHERE id = ?");
        $stmt->execute([$item_id]);
        echo json_encode(["success" => true, "message" => "Item approved successfully"]);
    } elseif ($action === 'reject') {
        $stmt = $pdo->prepare("UPDATE marketplace_items SET status = 'rejected' WHERE id = ?");
        $stmt->execute([$item_id]);
        echo json_encode(["success" => true, "message" => "Item rejected successfully"]);
    } else {
        $stmt = $pdo->prepare("DELETE FROM marketplace_items WHERE id = ?");
        $stmt->execute([$item_id]);
        echo json_encode(["success" => true, "message" => "Item deleted successfully"]);
    }

} catch (\PDOException $e) {
    http_response_code(500);
    echo json_encode(["success" => false, "message" => "Database error: " . $e->getMessage()]);
}
?>
