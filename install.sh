#!/usr/bin/env bash

set -euo pipefail
shopt -s nullglob dotglob  # include hidden files, and skip literal pattern if empty

copy_item() {
  local src="$1"
  local dest="$2"

  # If destination is a directory and exists, handle recursively
  if [[ -d "$src" ]]; then
    mkdir -p "$dest"
    for item in "$src"/*; do
      [[ -e "$item" ]] || continue
      copy_item "$item" "$dest/$(basename "$item")"
    done
  else
    # If file exists at destination, prompt the user
    if [[ -e "$dest" ]]; then
      echo "File '$dest' already exists."
      while true; do
        read -r -p "Choose action ([a]ppend, [o]verwrite, [s]kip): " choice
        case "$choice" in
          a|A)
            cat "$src" >> "$dest"
            echo "Appended to '$dest'."
            break
            ;;
          o|O)
            cp -f "$src" "$dest"
            echo "Overwrote '$dest'."
            break
            ;;
          s|S)
            echo "Skipped '$dest'."
            break
            ;;
          *)
            echo "Invalid choice. Please enter 'a', 'o', or 's'."
            ;;
        esac
      done
    else
      # If file doesn't exist, just copy
      mkdir -p "$(dirname "$dest")"
      cp "$src" "$dest"
      echo "Copied '$src' -> '$dest'"
    fi
  fi
}

# Main
for item in files/*; do
  [[ -e "$item" ]] || continue
  copy_item "$item" "$HOME/$(basename "$item")"
done

