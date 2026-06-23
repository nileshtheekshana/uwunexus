<?php
require 'db.php';
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(["success" => false, "message" => "Method not allowed"]);
    exit();
}

$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['requester_id']) || !isset($data['event_id']) || !isset($data['status'])) {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "Missing fields"]);
    exit();
}

$requester_id = intval($data['requester_id']);
$event_id = intval($data['event_id']);
$new_status = $data['status'];

if (!in_array($new_status, ['pending', 'approved', 'rejected'])) {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "Invalid status value"]);
    exit();
}

try {
    // Only superadmin can change event status
    $stmt = $pdo->prepare("SELECT role FROM users WHERE id = ?");
    $stmt->execute([$requester_id]);
    $user = $stmt->fetch();

    if (!$user || $user['role'] !== 'superadmin') {
        http_response_code(403);
        echo json_encode(["success" => false, "message" => "Only superadmin can update event status"]);
        exit();
    }

    $stmt = $pdo->prepare("UPDATE events SET status = ? WHERE id = ?");
    $stmt->execute([$new_status, $event_id]);

    echo json_encode(["success" => true, "message" => "Event status updated to $new_status"]);
} catch (\PDOException $e) {
    http_response_code(500);
    echo json_encode(["success" => false, "message" => "Database error"]);
}
?>
