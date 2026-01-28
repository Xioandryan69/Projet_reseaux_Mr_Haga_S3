<?php 
$username = escapeshellarg($_POST['username']);
$password = escapeshellarg($_POST['password']);

exec("../samba.sh $username $password", $output, $code);
?>