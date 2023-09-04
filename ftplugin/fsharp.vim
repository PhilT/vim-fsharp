if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

let s:save_cpo = &cpo
set cpo&vim

setlocal comments=:///,://!,://
setlocal commentstring=//%s
setlocal formatoptions-=t formatoptions+=croqnl
" j was only added in 7.3.541, so stop complaints about its nonexistence
silent! setlocal formatoptions+=j

" smartindent will be overridden by indentexpr if filetype indent is on, but
" otherwise it's better than nothing.
setlocal smartindent nocindent

setlocal suffixesadd=.fs

let b:undo_ftplugin = "setlocal formatoptions< comments< commentstring< suffixesadd<"

let &cpo = s:save_cpo
unlet s:save_cpo
