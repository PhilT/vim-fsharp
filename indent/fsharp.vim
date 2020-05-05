" Vim indent file
" Language:     FSharp
" Maintainer:   Phil Thompson        <phil@electricvisions.com>
" Created:      2020 May 04
" Last Change:
"
" Only load this indent file when no other was loaded.

echom 'Load indent script'

"if exists("b:did_indent")
"  finish
"endif

" Turned off for testing
" let b:did_indent = 1

setlocal indentexpr=FSharpIndent()
setlocal indentkeys&
"setlocal indentkeys+=0=let,0=module
setlocal indentkeys+=0\|,

" Only define the function once
"if exists("*GetFsharpIndent")
"  finish
"endif
"

function! FSharpIndent()
	" Line 0 always goes at column 0
	if v:lnum == 0
		return 0
	endif

  // TODO Trim spaces from current_line and previous_line

	let current_line = getline(v:lnum)
  let current_indent = indent(v:lnum)
  let previous_lnum = prevnonblank(v:lnum - 1)
  let previous_indent = indent(previous_lnum)
  let previous_line = getline(previous_lnum)
  let width = shiftwidth()
  let indent = 0

  echom 'Running indent script'

  " let func =
  " module Module =
  if previous_line =~ '^\s*\(let\|module\).*=\s*$'
    echom 'let!'
    let indent = previous_indent + width

  " | match expr
  "
  elseif previous_line =~ '^\s*| .*$'
    if previous_line =~ '^.*->$'
      let indent = previous_indent
    else
      let indent = previous_indent + width
    endif

  " when expr ->
  elseif previous_line =~ '^\s*when.*->\s*$'
    "if //find the line with the pipe
    let indent = previous_indent + width

  " |
  elseif current_line =~ '^\s*|$' && previous_line !~ '^\s*match .* with'
    let indent = previous_indent - width
  else
    let indent = previous_indent
  endif

  " Two blank lines for end of function (dedent)
  if (previous_lnum + 3) == v:lnum
    echo 'Matched: End of function'
    let indent = previous_indent
  endif

  return indent
endfunction

