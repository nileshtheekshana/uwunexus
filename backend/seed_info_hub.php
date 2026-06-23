<?php
require 'db.php';

$dummyData = [
    // Procedures
    [
        'category' => 'procedure',
        'title' => 'Medical Submissions',
        'description' => "Medical certificates must be submitted to the medical center within 7 days of absence.\nEnsure it is endorsed by a government medical officer.",
        'contact_info' => '',
        'action_link' => '#',
        'action_text' => 'Download Form'
    ],
    [
        'category' => 'procedure',
        'title' => 'Semester Registration',
        'description' => "Registration for upcoming semesters must be completed through the online portal during the specified add/drop period.",
        'contact_info' => '',
        'action_link' => '#',
        'action_text' => 'Read Guidelines'
    ],
    [
        'category' => 'procedure',
        'title' => 'Library Membership',
        'description' => "First-year students must physically visit the main library with their student ID to activate their library lending privileges.",
        'contact_info' => '',
        'action_link' => '',
        'action_text' => ''
    ],
    // Hotlines
    [
        'category' => 'hotline',
        'title' => 'Security Office',
        'description' => '24/7 Campus Security',
        'contact_info' => '055 222 6480',
        'action_link' => '',
        'action_text' => ''
    ],
    [
        'category' => 'hotline',
        'title' => 'Medical Center',
        'description' => 'University Health Service',
        'contact_info' => '055 222 6481',
        'action_link' => '',
        'action_text' => ''
    ],
    [
        'category' => 'hotline',
        'title' => 'Student Affairs',
        'description' => 'Student Welfare and Counseling',
        'contact_info' => '055 222 6482',
        'action_link' => '',
        'action_text' => ''
    ],
    // Contacts
    [
        'category' => 'contact',
        'title' => 'Dr. A.B. Perera',
        'description' => 'Head of Department - CST',
        'contact_info' => 'hod.cst@uwu.ac.lk',
        'action_link' => '',
        'action_text' => ''
    ],
    [
        'category' => 'contact',
        'title' => 'Mr. C.D. Silva',
        'description' => 'IIT Course Coordinator',
        'contact_info' => 'coord.iit@uwu.ac.lk',
        'action_link' => '',
        'action_text' => ''
    ]
];

try {
    $stmt = $pdo->prepare("INSERT INTO info_hub_items (category, title, description, contact_info, action_link, action_text) VALUES (?, ?, ?, ?, ?, ?)");
    foreach ($dummyData as $item) {
        $stmt->execute([
            $item['category'], 
            $item['title'], 
            $item['description'], 
            $item['contact_info'], 
            $item['action_link'], 
            $item['action_text']
        ]);
    }
    echo "Dummy data successfully inserted.\n";
} catch (\PDOException $e) {
    echo "Error inserting dummy data: " . $e->getMessage() . "\n";
}
?>
