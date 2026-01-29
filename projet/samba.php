<?php
// API minimal pour administrer création site / sous-domaine / lister dossier
// Sécurité: utiliser token stocké en root (/etc/bubble_api_token)

header('Content-Type: text/plain; charset=utf-8');

// token
$token_file = '/etc/bubble_api_token';
$token = $_POST['token'] ?? '';

if (!file_exists($token_file) || trim(file_get_contents($token_file)) !== $token) {
    http_response_code(403);
    echo 'Unauthorized';
    exit;
}

function run_cmd($cmd) {
    // utilise sudo -n pour ne pas bloquer si mot de passe demandé
    $full = 'sudo -n ' . $cmd . ' 2>&1';
    exec($full, $out, $code);
    // si sudo retourne 1 et sortie contient "a password is required" => erreur sudoers
    $outstr = implode("\n", $out);
    if ($code !== 0 && stripos($outstr, 'password') !== false) {
        return ['out' => ["SUDO_ERROR: élévation refusée ou mot de passe requis. Vérifier /etc/sudoers.d/bubble-scripts"], 'code' => 1];
    }
    return ['out' => $out, 'code' => $code];
}

$action = $_POST['action'] ?? '';

if ($action === 'create_site') {
    $domain = $_POST['domain'] ?? '';
    $project_dir = $_POST['project_dir'] ?? '/home/itu/Documents/S3/Mr Haga/Projet_reseaux_Mr_Haga_S3/projet';
    $ip = $_POST['ip'] ?? '10.251.28.157';
    if (!preg_match('/^[a-zA-Z0-9.-]+$/', $domain)) { http_response_code(400); echo 'Invalid domain'; exit; }
    $script = '/home/itu/Documents/S3/Mr Haga/Projet_reseaux_Mr_Haga_S3/create_site.sh';
    $cmd = escapeshellcmd($script) . ' ' . escapeshellarg($domain) . ' ' . escapeshellarg($project_dir) . ' ' . escapeshellarg($ip);
    $r = run_cmd($cmd);
    foreach ($r['out'] as $l) echo $l, PHP_EOL;
    http_response_code($r['code'] === 0 ? 200 : 500);
    exit;
} elseif ($action === 'add_subdomain') {
    $sub = $_POST['sub'] ?? '';
    $ip = $_POST['ip'] ?? '10.251.28.157';
    if (!preg_match('/^[a-zA-Z0-9._-]+$/', $sub)) { http_response_code(400); echo 'Invalid subdomain'; exit; }
    $script = '/home/itu/Documents/S3/Mr Haga/Projet_reseaux_Mr_Haga_S3/add_subdomain.sh';
    $cmd = escapeshellcmd($script) . ' ' . escapeshellarg($sub) . ' ' . escapeshellarg($ip);
    $r = run_cmd($cmd);
    foreach ($r['out'] as $l) echo $l, PHP_EOL;
    http_response_code($r['code'] === 0 ? 200 : 500);
    exit;
} elseif ($action === 'list_folder') {
    $site = $_POST['site'] ?? '';
    if (!preg_match('/^[a-zA-Z0-9._-]+(\.[a-zA-Z0-9._-]+)*$/', $site)) { http_response_code(400); echo 'Invalid site'; exit; }
    $dir = "/var/www/html/{$site}";
    if (!is_dir($dir)) { http_response_code(404); echo 'Not found'; exit; }
    $entries = array_diff(scandir($dir), ['.','..']);
    foreach ($entries as $e) echo $e, PHP_EOL;
    exit;
} elseif ($action === 'create_samba_user') {
    $username = $_POST['username'] ?? '';
    $password = $_POST['password'] ?? '';
    if (!preg_match('/^[a-zA-Z0-9._-]{1,32}$/', $username) || strlen($password) < 6) { http_response_code(400); echo 'Invalid input'; exit; }
    $script = '/home/itu/Documents/S3/Mr Haga/Projet_reseaux_Mr_Haga_S3/samba.sh';
    $cmd = escapeshellcmd($script) . ' ' . escapeshellarg($username) . ' ' . escapeshellarg($password);
    $r = run_cmd($cmd);
    foreach ($r['out'] as $l) echo $l, PHP_EOL;
    http_response_code($r['code'] === 0 ? 200 : 500);
    exit;
} else {
    http_response_code(400);
    echo 'No action';
    exit;
}
?>