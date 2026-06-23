<?php
require 'db.php';
header('Content-Type: application/json');

$admin_view = isset($_GET['admin']) && $_GET['admin'] === 'true';
$seller_id = isset($_GET['seller_id']) ? intval($_GET['seller_id']) : null;

try {
    // If admin_view or specific seller, return all including hidden/pending. If not, only active.
    $whereClause = "WHERE m.status = 'active'";
    if ($admin_view) {
        $whereClause = "";
    } elseif ($seller_id) {
        $whereClause = "WHERE m.seller_id = " . $pdo->quote($seller_id);
    }

    $query = "
        SELECT 
            m.id, m.title, m.description, m.price, m.condition_state, m.status, m.created_at, m.contact_number, m.contact_email,
            c.name as category_name, c.icon as category_icon, m.category_id,
            u.full_name as seller_name, u.email,
            GROUP_CONCAT(img.image_url) as images
        FROM marketplace_items m
        JOIN marketplace_categories c ON m.category_id = c.id
        JOIN users u ON m.seller_id = u.id
        LEFT JOIN marketplace_images img ON m.id = img.item_id
        $whereClause
        GROUP BY m.id
        ORDER BY m.created_at DESC
    ";

    $stmt = $pdo->query($query);
    $items = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Format images string into array
    foreach ($items as &$item) {
        $item['images'] = $item['images'] ? explode(',', $item['images']) : [];
    }

    echo json_encode(["success" => true, "items" => $items]);
} catch (\PDOException $e) {
    http_response_code(500);
    echo json_encode(["success" => false, "message" => "Database error: " . $e->getMessage()]);
}
?>
