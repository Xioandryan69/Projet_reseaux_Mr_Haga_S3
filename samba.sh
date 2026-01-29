#!/bin/bash

# ===============================
# CONFIGURATION
# ===============================
SAMBA_BASE="/srv/samba/users"
QUOTA_MB=50
SHELL="/usr/sbin/nologin"

# ===============================
# ARGUMENTS
# ===============================
USERNAME="$1"
PASSWORD="$2"

if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
    echo "Usage: $0 <username> <password>"
    exit 1
fi

# Sécurité basique sur le nom
if ! [[ "$USERNAME" =~ ^[a-zA-Z0-9._-]+$ ]]; then
    echo "Nom d'utilisateur invalide"
    exit 1
fi

# ===============================
# VÉRIFICATIONS
# ===============================
if id "$USERNAME" &>/dev/null; then
    echo "Utilisateur déjà existant"
    exit 1
fi

# ===============================
# CRÉATION UTILISATEUR LINUX (virtuel)
# ===============================
useradd \
  --home-dir "$SAMBA_BASE/$USERNAME" \
  --create-home \
  --shell "$SHELL" \
  --comment "Samba virtual user" \
  "$USERNAME"

if [ $? -ne 0 ]; then
    echo "Erreur création utilisateur Linux"
    exit 1
fi

# ===============================
# PERMISSIONS
# ===============================
chown "$USERNAME:$USERNAME" "$SAMBA_BASE/$USERNAME"
chmod 700 "$SAMBA_BASE/$USERNAME"

# ===============================
# MOT DE PASSE SAMBA
# ===============================
(
echo "$PASSWORD"
echo "$PASSWORD"
) | smbpasswd -s -a "$USERNAME"

if [ $? -ne 0 ]; then
    echo "Erreur création mot de passe Samba"
    userdel -r "$USERNAME"
    exit 1
fi

# ===============================
# QUOTA 50 Mo (ext4 / xfs)
# ===============================
# 50 Mo = 51200 blocs de 1K
setquota -u "$USERNAME" $((QUOTA_MB*1024)) $((QUOTA_MB*1024)) 0 0 /

# ===============================
# SUCCÈS
# ===============================
echo "Utilisateur Samba '$USERNAME' créé avec quota ${QUOTA_MB}Mo"
exit 0
