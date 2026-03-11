CACHE_DIR="$HOME/.cache"
LAST_RUN_FILE="$CACHE_DIR/brewfile_check_last_run"
OUTPUT_FILE="$CACHE_DIR/brewfile_check_output"
LOCK_DIR="$CACHE_DIR/brewfile_check.lock"
TODAY="$(date +%F)"

mkdir -p "$CACHE_DIR"

if [[ -f "$LAST_RUN_FILE" && "$(cat "$LAST_RUN_FILE")" == "$TODAY" ]]; then
  # Already checked today: print the cached output immediately.
  [[ -f "$OUTPUT_FILE" ]] && cat "$OUTPUT_FILE"
else
  # Not checked today: show the last saved output, then refresh in background.
  [[ -f "$OUTPUT_FILE" ]] && cat "$OUTPUT_FILE"
  echo "Checking Homebrew in background for $TODAY..."

  if mkdir "$LOCK_DIR" 2>/dev/null; then
    (
      trap 'rmdir "$LOCK_DIR"' EXIT

      TMP_OUTPUT="$CACHE_DIR/brewfile_check_output.tmp"
      bash "$HOME/.dotfiles/script/brew_installation/check.sh" > "$TMP_OUTPUT"
      mv "$TMP_OUTPUT" "$OUTPUT_FILE"
      echo "$TODAY" > "$LAST_RUN_FILE"
    ) >/dev/null 2>&1 &!
  else
    echo "Homebrew check is already running in background."
  fi
fi
