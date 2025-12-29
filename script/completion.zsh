CACHE_DIR="$HOME/.cache"
LAST_RUN_FILE="$CACHE_DIR/brewfile_check_last_run"
OUTPUT_FILE="$CACHE_DIR/brewfile_check_output"
TODAY="$(date +%F)"

mkdir -p "$CACHE_DIR"

if [[ -f "$LAST_RUN_FILE" && "$(cat "$LAST_RUN_FILE")" == "$TODAY" ]]; then
  # already ran today → print cached output
  cat "$OUTPUT_FILE"
else
  # not run today → run, save output, then print
  OUTPUT="$(bash "$HOME/.dotfiles/script/brew_installation/check.sh")"
  echo "$OUTPUT" | tee "$OUTPUT_FILE"
  echo "$TODAY" > "$LAST_RUN_FILE"
fi