" Vim indent file
" Language:     FSharp
" Maintainer:   Phil Thompson        <phil@electricvisions.com>
" Created:      2020 May 04
" Last Change:
"
" Only load this indent file when no other was loaded.

if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

setlocal indentexpr=FSharpIndent()
setlocal indentkeys+=0=\|,0=\|],0=when,0=elif,0=else,0=\|\>

" Only define the function once
if exists("*GetFsharpIndent")
  finish
endif

" Debug logging
if $VIM_FS_VERBOSE == 'true'
  command! -nargs=1 Log echom <args>
else
  command! -nargs=1 Log echom
endif

function! s:TrimSpacesAndComments(line)
  let line = substitute(a:line, '\v(.*)\/\/.*', '\1', '')
  return substitute(line, '\v^\s*(.{-})\s*$', '\1', '')
endfunction

function! s:ScopedFind(regex, start_line, scope)
  let lnum = a:start_line
  let min_indent = a:scope - shiftwidth()
  let max_indent = a:scope
  let indent = min_indent
  let line = ""
  let in_comment = 0

  while lnum >= 0 && (
        \ in_comment || line == "" || indent > max_indent ||
        \ (line !~ a:regex && indent >= min_indent)
        \ )
    Log 'lnum:'.lnum.', indent:'.indent.', min_indent:'.min_indent.', max_indent:'.max_indent
    Log 'in_comment:'.in_comment.', line:'.line
    let lnum -= 1
    let line = getline(lnum)
    let indent = indent(lnum)

    " Indicate if we are in a multiline comment
    if line =~ '*)$'
      let in_comment = 1
    endif
    if line =~ '^\s*(*'
      let in_comment = 0
    endif
  endwhile

  Log 'ScopedFind matched on line '.lnum.': ['.line.']'
  return line =~ a:regex ? lnum : -1
endfunction

function! s:IsInCommentOrString()
  let symbol_type = synIDattr(synID(line("."), col("."), 0), "name")
  Log 'IsInCommentOrString: '.symbol_type.' at line '.line('.').', col '.col('.')
  return (symbol_type =~? 'comment\|string')
endfunction

function! s:SkipFunc()
  return s:IsInCommentOrString()
endfunction

function! s:FindPair(start_word, middle_word, end_word)
  Log 'FindPair: Currently at line: '.line('.').' and column: '.col('.')

  " Make sure we're inside the pair if outside but doesn't affect
  " if we're already inside due to auto-pairs
  execute 'normal! h'
  let lnum = searchpair(a:start_word, a:middle_word, a:end_word,
        \ 'bWn', 's:SkipFunc()')

  Log 'FindPair matched on line '.lnum.': ['.getline(lnum).']'
  return lnum
endfunction

function! s:IndentPair(start_word, middle_word, end_word)
  return indent(s:FindPair(a:start_word, a:middle_word, a:end_word))
endfunction

function! FSharpIndent()
	let current_line = s:TrimSpacesAndComments(getline(v:lnum))
  let current_indent = indent(v:lnum)
  let previous_lnum = prevnonblank(v:lnum - 1)
  let previous_indent = indent(previous_lnum)
  let previous_line = s:TrimSpacesAndComments(getline(previous_lnum))
  let width = shiftwidth()
  let indent = 0

  Log 'Detecting...'

	if v:lnum == 0
    Log '! at line 0. Setting indent to 0'
    let indent = 0

  elseif current_line =~ '^}$'
    let indent = s:IndentPair('{', '', '}')
    Log '! dedent `}`: '.indent

  elseif current_line =~ '^\(]\||]\)$'
    let indent = s:IndentPair('\[', '', '\]')
    Log '! dedent `]`: '.indent

  elseif current_line =~ '^)$'
    let indent = s:IndentPair('(', '', ')')
    Log '! dedent `)`: '.indent

  elseif current_line =~ '^|$'
    Log '! start of match case or DU case'
    " Search for type, match and terminate on let
    let lnum = s:ScopedFind('^\s*\(type\|'
          \ .'match\|'
          \ .'let \w\+ .+ =\s*$\)',
          \ v:lnum, current_indent)
    let line = lnum == -1 ? "" : getline(lnum)

    if line =~ '^\s*type'
      let indent = indent(lnum) + width
    elseif line =~ '^\s*match'
      let indent = indent(lnum)
      let indent -= previous_line =~ '^| _ ->' ? width : 0
    elseif line =~ '^\s*let'
      let indent = current_indent
    else
      let indent = previous_line
    endif

  elseif current_line =~ '^|>$'
    Log '! `|>` pipeline operator on current line'
    let indent = previous_indent

  elseif current_line =~ '^when$'
    Log '! `when` in match expression'
    let indent = previous_indent + width

  elseif current_line =~ '^\(elif\|else\)$'
    Log '! `elif/else` on current line'
    if previous_line =~ '^\(if\|elif\)'
      let indent = previous_indent
    else
      let indent = previous_indent - width
    endif

  elseif previous_line =~ '^\(let\|module\).*=$'
    Log '! let/module ='
    let indent = previous_indent + width

  elseif previous_line =~ '^\(let\|type\).*=\(\s\({\|[\|[|\)\)\?$'
    Log '! type/record/array/list'
    let indent = previous_indent + width

  elseif previous_line =~ '^\([\|[|\|{\|[{\|(\)$'
    Log '! list/record/tuple'
    let indent = previous_indent + width

  elseif previous_line =~ '^{ .\+ with$'
    Log '! record copy and update expression (same line)'
    let indent = previous_indent + width + width

  elseif previous_line =~ '^.\+ with$'
    Log '! record copy and update expression (newline)'
    let indent = previous_indent + width

  elseif previous_line =~ '(fun\s.*->$'
    Log '! lambda'
    let indent = previous_indent + width

  elseif previous_line =~ '^| .*->$'
    Log '! match result expression'
    let indent = previous_indent + width
    Log 'indenting to '.indent.', Width: '.width.', Previous: '.previous_indent
    Log 'prev line:['.getline(previous_lnum).']'

  elseif previous_line =~ '^|>$'
    Log '! `|>` on previous line'
    let indent = previous_indent + width

  elseif (previous_lnum + 3) <= v:lnum
    Log '! two blank lines for end of function'
    let lnum = s:ScopedFind('^\s*let \w\+ .\+ =\s*$', v:lnum, previous_indent)
    let line = lnum == -1 ? "" : getline(lnum)

    if line =~ '^\s*let'
      let indent = indent(lnum)
    else
      let indent = 0
    endif

  elseif (previous_lnum + 2) <= v:lnum
    Log '! one blank line for end of code block'
    let lnum = s:ScopedFind('^\s*\(if .* then\|'
          \ .'let \w\+ .\+ =\s*\|'
          \ .'let .*=\s*\|'
          \ .').*\|'.
          \ '.*(fun .* ->$\)$',
          \ v:lnum, previous_indent)
    let line = lnum == -1 ? "" : getline(lnum)

    if line =~ '^\s*\(if .* then\)$'
      let indent = indent(lnum)
    elseif line =~ '^\s*let \w\+ .\+ =\s*\|(fun .* ->$'
      let indent = indent(lnum) + width
    elseif line =~ '^\s*let'
      let indent = indent(lnum)
    else
      let indent = previous_indent
    endif

  elseif previous_line =~ '^\(if\|elif\) .* then$'
        \ || previous_line =~ '^else$'
    Log '! if/elif then'
    let indent = previous_indent + width

  else
    Log '- keep indent of previous line'
    Log 'line matched ['.line.']'
    let indent = previous_indent

  endif

  return indent
endfunction

