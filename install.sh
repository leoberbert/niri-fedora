#!/usr/bin/env bash
# Installer for the niri-fedora setup.
#
#   config/  -> rendered into ~/.config/<name>
#   share/   -> rendered into $NIRICONF (default ~/.local/share/niri-fedora)
#
# Files in the repo use two placeholders, replaced at install time:
#   @HOME@      -> $HOME
#   @NIRICONF@  -> install dir for share/ (scripts, waybar, dunst, ...)
#
# Usage: ./install.sh [--skip-packages] [--skip-wal]
set -euo pipefail

REPO=$(dirname "$(realpath "$0")")
NIRICONF=${NIRICONF:-$HOME/.local/share/niri-fedora}
CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
STAMP=$(date +%Y%m%d%H%M%S)

SKIP_PACKAGES=false
SKIP_WAL=false
for arg in "$@"; do
  case $arg in
    --skip-packages) SKIP_PACKAGES=true ;;
    --skip-wal) SKIP_WAL=true ;;
    -h | --help)
      sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "[ERROR] unknown option: $arg" >&2
      exit 1
      ;;
  esac
done

info() { echo "[INFO] $*"; }
warn() { echo "[WARN] $*" >&2; }
die() { echo "[ERROR] $*" >&2; exit 1; }

install_packages() {
  command -v dnf &>/dev/null || die "dnf not found, this setup targets Fedora."

  # swaylock-effects comes from COPR
  sudo dnf copr enable -y eddsalkield/swaylock-effects
  sudo dnf swap -y swaylock swaylock-effects || true
  sudo dnf install -y \
    brightnessctl cargo cliphist dunst fd-find fuzzel figlet gum git \
    ImageMagick lz4-devel libxkbcommon-devel nautilus niri pamixer pavucontrol \
    playerctl polkit-kde power-profiles-daemon python3-gobject python3-pip \
    rofi starship swaybg swayidle udiskie waybar wayland-devel \
    wayland-protocols-devel wireplumber wl-clipboard wlogout xwayland-satellite

  if ! command -v awww &>/dev/null || ! command -v awww-daemon &>/dev/null; then
    local src
    src=$(mktemp -d)
    git clone --depth 1 https://codeberg.org/LGFae/awww "$src"
    # rustix >= 1.1 makes stdio::stdout/stderr unsafe; upstream does not wrap these calls yet
    sed -i 's|let stdout = rustix::stdio::stdout();|let stdout = unsafe { rustix::stdio::stdout() };|; s|let stderr = rustix::stdio::stderr();|let stderr = unsafe { rustix::stdio::stderr() };|' \
      "$src/daemon/src/cli.rs" "$src/daemon/src/main.rs"
    cargo install --locked --path "$src/client"
    cargo install --locked --path "$src/daemon"
    rm -rf "$src"
  fi

  command -v wal &>/dev/null || pip install --user pywal
}

# render_tree SRC DST: copy SRC to DST replacing the placeholders in text files.
render_tree() {
  local src=$1 dst=$2 f rel
  while IFS= read -r -d '' f; do
    rel=${f#"$src"/}
    mkdir -p "$dst/$(dirname "$rel")"
    if grep -Iq . "$f"; then
      sed -e "s|@NIRICONF@|$NIRICONF|g" -e "s|@HOME@|$HOME|g" "$f" >"$dst/$rel"
    else
      cp "$f" "$dst/$rel"
    fi
    chmod --reference="$f" "$dst/$rel"
  done < <(find "$src" -type f -print0)
}

backup() {
  local target=$1
  if [ -L "$target" ]; then
    rm "$target"
  elif [ -e "$target" ]; then
    mv "$target" "$target.bak.$STAMP"
    info "previous $target moved to $target.bak.$STAMP"
  fi
}

install_config() {
  local dir name
  for dir in "$REPO"/config/*; do
    name=$(basename "$dir")
    case $name in
      wal) # only the templates are managed; ~/.config/wal may hold user schemes
        mkdir -p "$CONFIG_HOME/wal"
        backup "$CONFIG_HOME/wal/templates"
        render_tree "$dir/templates" "$CONFIG_HOME/wal/templates"
        ;;
      *)
        backup "$CONFIG_HOME/$name"
        render_tree "$dir" "$CONFIG_HOME/$name"
        ;;
    esac
    info "installed config/$name"
  done

  rm -rf "$NIRICONF"
  render_tree "$REPO/share" "$NIRICONF"
  info "installed share/ -> $NIRICONF"
}

generate_wal_colors() {
  if ! command -v wal &>/dev/null; then
    warn "pywal (wal) not found; wlogout/rofi colors will be missing."
    return
  fi
  # -n no wallpaper, -s no terminal colors, -t no tty, -e no reload
  wal -q -n -s -t -e -i "$NIRICONF/wallpapers/workspace.jpg"
  info "pywal colors generated"
}

$SKIP_PACKAGES || install_packages
install_config
$SKIP_WAL || generate_wal_colors

command -v zashterminal &>/dev/null ||
  warn "zashterminal (terminal bound to Mod+Return) not found in PATH; install it separately."

if command -v niri &>/dev/null; then
  if niri validate --config "$CONFIG_HOME/niri/config.kdl" &>/dev/null; then
    info "niri config is valid. Log out and pick niri in the session menu."
  else
    warn "niri config invalid:"
    niri validate --config "$CONFIG_HOME/niri/config.kdl" || true
    exit 1
  fi
fi
