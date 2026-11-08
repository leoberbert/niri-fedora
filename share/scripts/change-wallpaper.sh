#!/bin/bash
printf '\033]0;Wallpaper Selector\007'
wallpaper_dir="${WALLPAPER_DIR:-$HOME/Pictures/wallpapers}"
niriconf="@NIRICONF@"
wallpapers_kdl="@HOME@/.config/niri/wallpapers.kdl"
export GUM_CHOOSE_HEADER_FOREGROUND="#d8dadd"
export GUM_CHOOSE_SELECTED_FOREGROUND="#758A9B"
export GUM_CHOOSE_CURSOR_FOREGROUND="#758A9B"

finish() {
  read -n 1 -s -r -p "[INFO] Press any key to finish..."
  echo
}

# deps check
deps=(magick swaybg awww awww-daemon gum)
missing=()
for dep in "${deps[@]}"; do
  command -v "$dep" &>/dev/null || missing+=("$dep")
done
if [[ -n ${missing[*]} ]]; then
  echo "[ERROR] missing dependencies: ${missing[*]}"
  finish
  exit 1
fi

# main logic
mkdir -p "$wallpaper_dir"
images=$(find "$wallpaper_dir" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) -printf '%P\n' | sort)
if [ -z "$images" ]; then
  echo "[ERROR] No image file found"
  echo "[INFO] Place your wallpapers in $wallpaper_dir"
  finish
  exit 1
fi
choice=$(echo "$images" | gum choose --header 'Choose your wallpaper: ') || exit 1
mode=$(printf '%s\n' stretch fill fit center tile | gum choose --header "Choose wallpaper mode: ") || exit 1
image="$wallpaper_dir/$choice"
ext="${image##*.}"
ext="${ext,,}"
[ "$ext" = jpeg ] && ext=jpg

echo "[INFO] New wallpaper: $image"
workspace="$niriconf/wallpapers/workspace.$ext"
backdrop="$niriconf/wallpapers/backdrop.$ext"
# drop previous files with another extension so they cannot be picked up by mistake
for old in "$niriconf"/wallpapers/{workspace,backdrop}.*; do
  case $old in
    "$workspace" | "$backdrop") ;;
    *) rm -f "$old" ;;
  esac
done
cp -f "$image" "$workspace" || { finish; exit 1; }

canvas_color=$(magick "$workspace" -crop x1+0+0 -resize 1x1 txt:- | grep -o '#[0-9A-Fa-f]\{6\}' | head -n1)
canvas_color=${canvas_color:-#000000}

echo "[INFO] Creating new overview backdrop..."
magick "$workspace" -scale 10% -blur 0x2.5 -resize 1000% "$backdrop" || { finish; exit 1; }

# persist for the next login
workspace_cmd="swaybg -i $workspace -m $mode -c '$canvas_color'"
backdrop_cmd="awww-daemon \& awww img $backdrop"
sed -i "s|^spawn-sh-at-startup \"swaybg.*|spawn-sh-at-startup \"$workspace_cmd\"|" "$wallpapers_kdl"
sed -i "s|^spawn-sh-at-startup \"awww.*img.*|spawn-sh-at-startup \"$backdrop_cmd\"|" "$wallpapers_kdl"

# apply now
pkill swaybg
setsid -f sh -c "$workspace_cmd" >/dev/null 2>&1
pgrep -x awww-daemon >/dev/null || setsid -f awww-daemon >/dev/null 2>&1
sleep 0.5
awww img "$backdrop"

echo "[INFO] Done!"
finish
