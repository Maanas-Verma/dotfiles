# lla overides for ls
#   using a beautiful lib writtern in rust
#   https://github.com/chaqchase/lla
#   `brew install lla`
if lla &>/dev/null; then
  alias ls="lla -g"
  alias ltree="lla -t -d 3"
  alias ltable="lla -T"
  alias la='lla -l'
  alias lgit='lla -G'
  alias ltimeline='lla --timeline'
  alias lstorage='lla -S'
  alias lfuzzy='lla --fuzzy'
fi