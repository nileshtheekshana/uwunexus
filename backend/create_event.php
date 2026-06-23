<?php
require 'db.php';
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(["success" => false, "message" => "Method not allowed"]);
    exit();
}

$data = json_decode(file_get_contents("php://input"), true);

$required = ['title', 'event_date', 'event_time', 'location', 'organized_by', 'category', 'requester_id'];
foreach ($required as $field) {
    if (!isset($data[$field]) || trim($data[$field]) === '') {
        http_response_code(400);
        echo json_encode(["success" => false, "message" => "Missing required field: $field"]);
        exit();
    }
}

$requester_id = intval($data['requester_id']);

try {
    $stmt = $pdo->prepare("SELECT role FROM users WHERE id = ?");
    $stmt->execute([$requester_id]);
    $user = $stmt->fetch();

    if (!$user || !in_array($user['role'], ['superadmin', 'clubadmin'])) {
        http_response_code(403);
        echo json_encode(["success" => false, "message" => "Only admins can create events"]);
        exit();
    }

    // superadmin → approved immediately, clubadmin → pending
    $status = ($user['role'] === 'superadmin') ? 'approved' : 'pending';

    $stmt = $pdo->prepare("INSERT INTO events (title, description, event_date, event_time, location, organized_by, category, image_url, status, created_by)
                            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
    $stmt->execute([
        trim($data['title']),
        isset($data['description']) ? trim($data['description']) : null,
        $data['event_date'],
        $data['event_time'],
        trim($data['location']),
        trim($data['organized_by']),
        $data['category'],
        isset($data['image_url']) && $data['image_url'] !== '' ? $data['image_url'] : null,
        $status,
        $requester_id
    ]);

    $new_id = $pdo->lastInsertId();
    echo json_encode(["success" => true, "message" => "Event created successfully", "status" => $status, "id" => $new_id]);
} catch (\PDOException $e) {
    http_response_code(500);
    echo json_encode(["success" => false, "message" => "Database error: " . $e->getMessage()]);
}
?>
