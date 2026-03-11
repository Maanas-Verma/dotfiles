# Check for Homebrew
if test ! $(which cargo)
then
  echo "  Installing cargo for you."

  # Install the correct homebrew for each OS type
  if test "$(uname)" = "Darwin"
  then
      curl https://sh.rustup.rs -sSf | sh
  fi
fi
