<?php

sleep(1);

$data = $_POST['photo'];
$meta = $_POST['meta'];

$type = $meta['type'];

list($type, $data) = explode(';', $data);
list (, $data) = explode(',', $data);
$data = base64_decode($data);

$extension = explode('/', $meta['type'])[1];
$file = md5(microtime(true)).'.'.$extension;

$success = file_put_contents($file, $data);

if ($success) {
    http_response_code(200);
    echo json_encode(['file' => $file, 'url' => "http://$_SERVER[HTTP_HOST]/$file"]);

    return true;
}

http_response_code(400);
echo 'FAILED to upload';

return false;
