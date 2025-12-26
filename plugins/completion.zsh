
# zsh autosuggestions
# Uses zsh autocompletion for interactive. Assumes an install
# `zsh-autocompletion` script at $completion below (this is where Homebrew
# tosses it, at least).
completion=$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

if test -f $completion
then
  source $completion
fi
