<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

// Check if it's a JSON request (base64 image)
$json = file_get_contents('php://input');
$data = json_decode($json, true);

if(isset($data['image'])) {
    // Base64 image handle karo
    $base64 = $data['image'];
    if(preg_match('/^data:image\/(\w+);base64,/', $base64, $type)) {
        $base64 = substr($base64, strpos($base64, ',') + 1);
        $type = strtolower($type[1]);
        
        $image = base64_decode($base64);
        
        if($image !== false) {
            $filename = uniqid() . '.' . $type;
            $upload_path = 'uploads/' . $filename;
            
            if(!file_exists('uploads')) {
                mkdir('uploads', 0777, true);
            }
            
            if(file_put_contents($upload_path, $image)) {
                $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? 'https' : 'http';
                $host = $_SERVER['HTTP_HOST'];
                $full_url = $protocol . '://' . $host . '/' . $upload_path;
                
                echo json_encode([
                    'success' => true,
                    'url' => $full_url,
                    'message' => 'Image uploaded successfully'
                ]);
                exit;
            }
        }
    }
    
    echo json_encode(['success' => false, 'message' => 'Invalid base64 image']);
    exit;
}

// Normal file upload
if(isset($_FILES['image']) && $_FILES['image']['error'] == 0) {
    $allowed = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    $filename = $_FILES['image']['name'];
    $ext = strtolower(pathinfo($filename, PATHINFO_EXTENSION));

    if(in_array($ext, $allowed)) {
        $new_filename = uniqid() . '.' . $ext;
        $upload_path = 'uploads/' . $new_filename;
        
        if(!file_exists('uploads')) {
            mkdir('uploads', 0777, true);
        }
        
        if(move_uploaded_file($_FILES['image']['tmp_name'], $upload_path)) {
            $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? 'https' : 'http';
            $host = $_SERVER['HTTP_HOST'];
            $full_url = $protocol . '://' . $host . '/' . $upload_path;
            
            echo json_encode([
                'success' => true,
                'url' => $full_url,
                'message' => 'Image uploaded successfully'
            ]);
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'Failed to move uploaded file'
            ]);
        }
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Invalid file type. Allowed: jpg, jpeg, png, gif, webp'
        ]);
    }
} else {
    echo json_encode([
        'success' => false,
        'message' => 'No file uploaded or upload error'
    ]);
}
?>