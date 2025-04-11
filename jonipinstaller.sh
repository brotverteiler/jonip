#!/bin/bash

# Sicherstellen, dass das Skript mit root-Rechten ausgeführt wird
if [[ $EUID -ne 0 ]]; then
  echo "Bitte führe dieses Skript als root aus."
  exit 1
fi

# Variablen
ETC_DIR="/etc/jonip"
ETC_TARGET="$ETC_DIR/jonip.sh"
LOG_DIR="/var/log/jonIP"
LOG_FILE="$LOG_DIR/jonip.log"
JONIP_URL="https://raw.githubusercontent.com/brotverteiler/jonip/main/jonip.sh"
BASHRC="/home/$SUDO_USER/.bashrc"
ALIAS_DEFINITION="alias IP-Config='/etc/jonip/jonip.sh'"

# Ordner erstellen
mkdir -p "$ETC_DIR"
mkdir -p "$LOG_DIR"

# jonip.sh von GitHub herunterladen
echo "Lade jonip.sh von GitHub..."
curl -fsSL "$JONIP_URL" -o "$ETC_TARGET"

if [[ $? -ne 0 ]]; then
  echo "Fehler: Konnte jonip.sh nicht herunterladen!"
  exit 1
fi

# Rechte setzen
chmod +x "$ETC_TARGET"
touch "$LOG_FILE"
chown "$SUDO_USER":"$SUDO_USER" "$LOG_FILE"
chmod 664 "$LOG_FILE"

# Alias setzen, falls noch nicht vorhanden
if ! grep -Fxq "$ALIAS_DEFINITION" "$BASHRC"; then
    echo "$ALIAS_DEFINITION" >> "$BASHRC"
    echo "Alias 'IP-Config' wurde zu $BASHRC hinzugefügt."
else
    echo "Alias 'IP-Config' existiert bereits in $BASHRC."
fi

# Optional: Logeintrag
echo "Installation abgeschlossen am $(date)" >> "$LOG_FILE"

echo "Fertig! Starte dein Terminal neu oder gib 'source ~/.bashrc' ein"
source ~/.bashrc
