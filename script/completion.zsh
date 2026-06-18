CACHE_DIR="$HOME/.cache"
LAST_RUN_FILE="$CACHE_DIR/brewfile_check_last_run"
OUTPUT_FILE="$CACHE_DIR/brewfile_check_output"
BREWFILE_HASH_FILE="$CACHE_DIR/brewfile_check_brewfile_hash"
LOCK_DIR="$CACHE_DIR/brewfile_check.lock"
BREWFILE_PATH="$HOME/.dotfiles/Brewfile"
TODAY="$(date +%F)"

mkdir -p "$CACHE_DIR"

CURRENT_BREWFILE_HASH="$(shasum -a 256 "$BREWFILE_PATH" 2>/dev/null | awk '{print $1}')"
CACHED_BREWFILE_HASH="$([[ -f "$BREWFILE_HASH_FILE" ]] && cat "$BREWFILE_HASH_FILE")"

print_cached_output() {
  if [[ -n "$CURRENT_BREWFILE_HASH" && "$CURRENT_BREWFILE_HASH" == "$CACHED_BREWFILE_HASH" ]]; then
    [[ -f "$OUTPUT_FILE" ]] && cat "$OUTPUT_FILE"
  fi
}

if [[ -f "$LAST_RUN_FILE" && "$(cat "$LAST_RUN_FILE")" == "$TODAY" && "$CURRENT_BREWFILE_HASH" == "$CACHED_BREWFILE_HASH" ]]; then
  # Already checked today: print the cached output immediately.
  print_cached_output
else
  # Not checked today: show the last saved output, then refresh in background.
  print_cached_output
  echo "Checking Homebrew in background for $TODAY..."

  if [[ -d "$LOCK_DIR" ]]; then
    LOCK_PID="$([[ -f "$LOCK_DIR/pid" ]] && cat "$LOCK_DIR/pid")"
    if [[ -z "$LOCK_PID" ]] || ! kill -0 "$LOCK_PID" 2>/dev/null; then
      rm -f "$LOCK_DIR/pid"
      rmdir "$LOCK_DIR" 2>/dev/null
    elif find "$LOCK_DIR" -prune -mmin +120 | grep -q .; then
      echo "Homebrew check is already running in background."
      return 0 2>/dev/null || exit 0
    fi
  fi

  if mkdir "$LOCK_DIR" 2>/dev/null; then
    (
      trap 'rm -f "$LOCK_DIR/pid"; rmdir "$LOCK_DIR"' EXIT

      TMP_OUTPUT="$CACHE_DIR/brewfile_check_output.tmp"
      if bash "$HOME/.dotfiles/script/brew_installation/check.sh" > "$TMP_OUTPUT"; then
        mv "$TMP_OUTPUT" "$OUTPUT_FILE"
        echo "$CURRENT_BREWFILE_HASH" > "$BREWFILE_HASH_FILE"
        echo "$TODAY" > "$LAST_RUN_FILE"
      else
        rm -f "$TMP_OUTPUT"
      fi
    ) >/dev/null 2>&1 &!
    echo "$!" > "$LOCK_DIR/pid"
  else
    echo "Homebrew check is already running in background."
  fi
fi
