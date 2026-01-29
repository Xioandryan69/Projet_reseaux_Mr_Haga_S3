<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="utf-8">
  <title>Administration bubble.mg</title>
  <style>body{font-family:Arial;padding:20px} form{margin-bottom:16px}</style>
</head>
<body>
  <h1>Administration bubble.mg</h1>
  <?php
    $token_file = '/etc/bubble_api_token';
    $TOKEN = 'CHANGEME_TOKEN';
    if (is_readable($token_file)) {
      $t = trim(@file_get_contents($token_file));
      if ($t !== '') { $TOKEN = $t; }
    }
  ?>
  <form method="post" action="samba.php">
    <input type="hidden" name="token" value="<?php echo htmlspecialchars($TOKEN); ?>">
    <input type="hidden" name="action" value="create_site">
    <label>Domaine (ex: www.bubble.mg): <input name="domain" required></label>
    <label>Project dir (optionnel): <input name="project_dir" value="/home/itu/Documents/S3/Mr Haga/Projet_reseaux_Mr_Haga_S3/projet"></label>
    <label>IP (optionnel): <input name="ip" value="10.251.28.157"></label>
    <button type="submit">Créer site</button>
  </form>

  <form method="post" action="samba.php">
    <input type="hidden" name="token" value="<?php echo htmlspecialchars($TOKEN); ?>">
    <input type="hidden" name="action" value="add_subdomain">
    <label>Sous-domaine (ex: blog) : <input name="sub" required></label>
    <label>IP (optionnel): <input name="ip" value="10.251.28.157"></label>
    <button type="submit">Ajouter sous-domaine</button>
  </form>

  <form method="post" action="samba.php">
    <input type="hidden" name="token" value="<?php echo htmlspecialchars($TOKEN); ?>">
    <input type="hidden" name="action" value="list_folder">
    <label>Site à lister (ex: www.bubble.mg) : <input name="site" required></label>
    <button type="submit">Lister dossier</button>
  </form>

  <form method="post" action="samba.php">
    <input type="hidden" name="token" value="<?php echo htmlspecialchars($TOKEN); ?>">
    <input type="hidden" name="action" value="create_samba_user">
    <label>Username: <input name="username" required></label>
    <label>Password: <input name="password" type="password" required></label>
    <button type="submit">Créer utilisateur Samba</button>
  </form>

  <p>Après création du site, les fichiers du dossier projet (index.php, samba.php, ...) sont copiés automatiquement dans /var/www/html/&lt;domaine&gt; par create_site.sh.</p>
</body>
</html>