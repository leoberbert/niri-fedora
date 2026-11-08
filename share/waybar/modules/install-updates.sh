#!/bin/bash
printf '\033]0;Updater\007'
figlet "Updates" -f slant -w 44 -c
echo ""
sleep 0.1

sudo dnf upgrade --refresh

echo ""
echo "[INFO] OK"
read -n 1 -s -r -p "[INFO] Press any key to finish..."
