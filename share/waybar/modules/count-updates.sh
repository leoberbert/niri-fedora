#!/bin/bash
updates=$(dnf -q check-update 2>/dev/null | grep -cE '^[^[:space:]]+\.[^[:space:]]+[[:space:]]+[^[:space:]]+[[:space:]]+[^[:space:]]+$')
printf '{"text": "%s", "alt": "%s", "tooltip": "%s updates"}' "$updates" "$updates" "$updates"
