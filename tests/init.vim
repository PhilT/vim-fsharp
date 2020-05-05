filetype off
set rtp+=$XDG_CONFIG_HOME/nvim/plugged/vader.vim
"set rtp+=$XDG_CONFIG_HOME/nvim/plugged/vim-pandoc-syntax
let &rtp.=','.expand('%:p:h:h')
filetype plugin indent on
set shiftwidth=2
syntax enable

