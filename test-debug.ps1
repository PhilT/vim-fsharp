$env:DEBUG_VIMFS="true"
nvim -Es -V1 -Nu tests/vimrc "+Vader! tests/fun.vader"
$env:DEBUG_VIMFS="false"

