#!/usr/bin/env bash
# Pull the live config back into the repo (inverse of install.sh), turning
# absolute paths back into @HOME@ / @NIRICONF@ placeholders.
#
# Usage: ./sync.sh
set -euo pipefail

REPO=$(dirname "$(realpath "$0")")
NIRICONF=${NIRICONF:-$HOME/.local/share/niri-fedora}
CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}

# pull_tree LIVE_DIR REPO_DIR: mirror LIVE_DIR into REPO_DIR with placeholders restored.
pull_tree() {
  local live=$1 dst=$2 f rel
  [ -d "$live" ] || { echo "[WARN] missing $live, skipped" >&2; return; }
  rm -rf "$dst"
  while IFS= read -r -d '' f; do
    rel=${f#"$live"/}
    mkdir -p "$dst/$(dirname "$rel")"
    if grep -Iq . "$f"; then
      # NIRICONF first: it lives under $HOME
      sed -e "s|$NIRICONF|@NIRICONF@|g" -e "s|$HOME|@HOME@|g" "$f" >"$dst/$rel"
    else
      cp "$f" "$dst/$rel"
    fi
    chmod --reference="$f" "$dst/$rel"
  done < <(find "$live" -type f -print0)
}

for dir in "$REPO"/config/*; do
  name=$(basename "$dir")
  case $name in
    wal) pull_tree "$CONFIG_HOME/wal/templates" "$dir/templates" ;;
    *) pull_tree "$CONFIG_HOME/$name" "$dir" ;;
  esac
done

for dir in "$REPO"/share/*; do
  pull_tree "$NIRICONF/$(basename "$dir")" "$dir"
done

git -C "$REPO" status --short
