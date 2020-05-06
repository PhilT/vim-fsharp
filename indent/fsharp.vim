" Vim indent file
" Language:     FSharp
" Maintainer:   Phil Thompson        <phil@electricvisions.com>
" Created:      2020 May 04
" Last Change:
"
" Only load this indent file when no other was loaded.

"if exists("b:did_indent")
"  finish
"endif

" Turned off for testing
" let b:did_indent = 1

setlocal indentexpr=FSharpIndent()
"setlocal indentkeys&
"setlocal indentkeys+=0=let,0=module
"setlocal indentkeys+=0=}
"setlocal indentkeys=0|
setlocal indentkeys+=0=\|,0=\|],0=when

" Only define the function once
"if exists("*GetFsharpIndent")
"  finish
"endif
"

function! TrimSpaces(line)
  return substitute(a:line, '\v^\s*(.{-})\s*$', '\1', '')
endfunction

function! ScopedFind(regex, regex2, start_line, scope)
  let lnum = a:start_line
  let min_indent = a:scope - shiftwidth()
  let indent = min_indent
  let line = ""

  while line !~ a:regex && line !~ a:regex2 && lnum >= 0 && indent >= min_indent
    echom 'lnum:'.lnum
    echom 'indent:'.indent
    echom 'min_indent:'.min_indent
    let lnum -= 1
    let line = getline(lnum)
    let indent = indent(lnum)
  endwhile

  echom '**** ScopedFind: ['.line.']'
  return line =~ a:regex || line =~ a:regex2 ? lnum : -1
endfunction


function! FSharpIndent()
	let current_line = TrimSpaces(getline(v:lnum))
  let current_indent = indent(v:lnum)
  let previous_lnum = prevnonblank(v:lnum - 1)
  let previous_indent = indent(previous_lnum)
  let previous_line = TrimSpaces(getline(previous_lnum))
  let width = shiftwidth()
  let indent = 0

  echom 'Detecting...'

	if v:lnum == 0
    echom 'Detected: At line 0. Setting indent to 0'
    let indent = 0

  elseif current_line =~ '^}\|]\||]\|)$'
    echom 'Detected: Dedent closing brackets: '.previous_indent
    let indent = previous_indent - width

  elseif current_line =~ '^|$'
    echom 'Detected: start of match case or DU case'
    let lnum = ScopedFind('^\s*\(type\|match\)', '^\s*let .*=$', v:lnum, current_indent)
    echom 'ScopedFind returned: '.lnum
    if lnum == -1
      let indent = previous_line
    elseif getline(lnum) =~ '^\s*type'
      let indent = indent(lnum) + width
      echom 'Matched DU type. Setting indent: '.indent
    elseif getline(lnum) =~ '^\s*match'
      let indent = indent(lnum)
    elseif getline(lnum) =~ '^\s*let'
      let indent = current_indent
    else
      throw 'Unhandled case "'.getline(lnum).'" in ScopedFind()'
    endif

  elseif current_line =~ '^when$'
    let indent = previous_indent + width

  elseif previous_line =~ '^\(let\|module\).*=$'
    echom 'Detected: let/module ='
    let indent = previous_indent + width

  elseif previous_line =~ '^\(let\|type\).*=\(\s\({\|[\|[|\)\)\?$'
    echom 'Detected: type/record/array/list'
    let indent = previous_indent + width

  elseif previous_line =~ '^[\|[|\|{$'
    echom 'Detected: list/record'
    let indent = previous_indent + width

  elseif previous_line =~ '(fun\s.*->$'
    echom 'Detected: lambda'
    let indent = previous_indent + width

  elseif previous_line =~ '^| .*->$'
    echom 'Detected: single line match case'
    let indent = previous_indent + width
"
  elseif (previous_lnum + 3) <= v:lnum
    echom 'Detected: Two blank lines for end of function'
    let indent = previous_indent - width

  else
    echom 'Default: Keep indent of previous line'
    let indent = previous_indent

  endif

  return indent
endfunction

