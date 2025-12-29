#!/bin/bash

# --- Configuration ---
# REPLACE THIS WITH YOUR ACTUAL FILE PATH
BREWFILE_PATH="$HOME/.dotfiles/Brewfile"

# Check if file exists
if [ ! -f "$BREWFILE_PATH" ]; then
    echo "Error: Brewfile not found at $BREWFILE_PATH"
    exit 1
fi

# Read file content
BREWFILE_CONTENT=$(cat "$BREWFILE_PATH")

# --- Logic ---

# 1. Get Lists of Currently Installed Packages
installed_casks=($(brew list --cask))
installed_formulae=($(brew list --installed-on-request))

# 2. Parse the Brewfile Content
# Extract names from lines starting with "brew " or "cask ", removing quotes
tracked_casks=$(echo "$BREWFILE_CONTENT" | grep "^cask " | awk "{print \$2}" | tr -d "'\"")
tracked_formulae=$(echo "$BREWFILE_CONTENT" | grep "^brew " | awk "{print \$2}" | tr -d "'\"")

# 3. Identify Missing Items
missing_casks=()
for cask in "${installed_casks[@]}"; do
    if ! echo "$tracked_casks" | grep -qx "$cask"; then
        missing_casks+=("$cask")
    fi
done

missing_formulae=()
for formula in "${installed_formulae[@]}"; do
    if ! echo "$tracked_formulae" | grep -qx "$formula"; then
        missing_formulae+=("$formula")
    fi
done

# --- Output ---

found_missing=false
IFS=","

if [ ${#missing_casks[@]} -gt 0 ]; then
    echo "Add below cask:"
    echo "    ${missing_casks[*]}"
    echo ""
    found_missing=true
fi

if [ ${#missing_formulae[@]} -gt 0 ]; then
    echo "Add below brew:"
    echo "    ${missing_formulae[*]}"
    echo ""
    found_missing=true
fi

unset IFS