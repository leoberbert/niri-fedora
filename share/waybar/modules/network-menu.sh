#!/bin/bash
printf '\033]0;nmtui\007'

if ! command -v nmtui &>/dev/null; then
  echo "[ERROR] nmtui not found. Install it with:"
  echo "        sudo dnf install NetworkManager-tui"
  echo ""
  read -n 1 -s -r -p "[INFO] Press any key to close..."
  exit 1
fi

exec nmtui connect
