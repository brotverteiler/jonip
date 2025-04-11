#!/bin/bash

# Sicherstellen, dass das Skript mit root-Rechten ausgeführt wird
if [[ $EUID -ne 0 ]]; then
  echo "Bitte führe dieses Skript als root aus."
  exit 1
fi

# Variablen
INSTALL_DIR="$(dirname "$(realpath "$0")")"
SOURCE_FILE="$INSTALL_DIR/jonip.sh"
ETC_DIR="/etc/jonip"
ETC_TARGET="$ETC_DIR/jonip.sh"

LOG_DIR="/var/log/jonIP"
LOG_FILE="$LOG_DIR/jonip.log"

# Log-Verzeichnis erstellen und leere Log-Datei anlegen
mkdir -p "$LOG_DIR"
touch "$LOG_FILE"

# Prüfen, ob die Quelldatei existiert
if [[ ! -f "$SOURCE_FILE" ]]; then
  echo "Die Datei jonip.sh wurde im aktuellen Verzeichnis nicht gefunden."
  echo "Installation Failed keine Sudo rechte" "$Log_File"
  exit 1
fi

# Ordner in /etc erstellen und Skript dorthin kopieren
mkdir -p "$ETC_DIR"
cp "$SOURCE_FILE" "$ETC_TARGET"
chmod +x "$ETC_TARGET"

# Alias hinzufügen, falls noch nicht vorhanden
ALIAS_DEFINITION="alias IP-Config='/etc/jonip/jonip.sh'"

# Nur für bash - du kannst das auf Wunsch auch auf zsh anpassen
BASHRC="/home/$SUDO_USER/.bashrc"

if ! grep -Fxq "$ALIAS_DEFINITION" "$BASHRC"; then
    echo "$ALIAS_DEFINITION" >> "$BASHRC"
    echo "Alias 'IP-Config' wurde zu $BASHRC hinzugefügt."
else
    echo "Alias 'IP-Config' existiert bereits in $BASHRC."
fi

# Optionale Nachricht
echo "jonip.sh wurde erfolgreich nach /etc/jonip kopiert."
echo "Leere Log-Datei wurde unter /var/log/jonIP/jonip.log erstellt."
