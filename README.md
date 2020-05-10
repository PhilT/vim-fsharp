# An Opinionated F# Indent and Syntax plugin for Vim

[![Build Status](https://travis-ci.org/PhilT/vim-fs.svg?branch=master)](https://travis-ci.org/PhilT/vim-fs)

## Status

* Indent: In-progress
* Syntax: Copied from [ionide-vim](https://github.com/ionide/Ionide-vim) for now
* Plugin: None

This plugin is currently focused on providing better indent support in F#. It's
currently incomplete (not all syntax is covered). If you'd like to see support
for some keywords do raise an issue (or a PR! ;) and I'll add it.


## Why?

* [vim-fsharp](https://github.com/fsharp/vim-fsharp) hasn't been touched in a
  couple of years and `indent/` is 4 years old
* Language features can be more easily provided by an LSP (e.g.
  [coc-fsharp](https://github.com/coc-extensions/coc-fsharp))
* Enhancements to indent rules can provide a better experience
* Other plugins don't improve the basic syntax and indent behaviour and seem to
  have issues on Windows platforms

## Features

* Robust indentation support
* 2 line breaks ends function
* Single line break ends let binding
* Automated tests - Rules can be added without breaking existing functionality
* Developed on Windows 10 with Neovim 0.4.3
* Tested in Neovim 0.4.3 and Vim 8.2
* Tested on Windows 10 and Ubuntu Linux 20.04
* Pure Vimscript

## Installation

Use your plugin manager. I use [vim-plug](https://github.com/junegunn/vim-plug)

```
Plug 'PhilT/vim-fs'
```

If you use [vim-polyglot](https://github.com/sheerun/vim-polyglot) be sure to
load **vim-fs** before it or `let g:polyglot_disabled = ['fsharp']` before
loading plugins.


## A list of indent rules

The following code snippets were all typed without pressing the TAB key. (See
[test case here](blob/master/tests/readme.vader))
This also serves as a bit of a style guide.

```fsharp
  // ### Array and List
  // The following applies to both arrays and lists.
  let anArray = [|
    item1
    item2
  |]


  let returnsList =
    [
      item1
      item2
    ]


  // ### Conditional
  let someFunc () =
    if someCond then doThing
    elif otherCond then doOther
    else doDefaultThing

    if someExpression then
      doSomething
    elif someOtherExpression then
      doAnotherThing
    else
      doSomethingElse

    // single blank line after if/else block to dedent


  // ### Lamba (`fun`)
  // Also supports auto-pairs
  List.map (fun x ->
    processMap
  )


  // ### Function (`let`)
  let someFunc args =
    doSomeStuff
    doMoreStuff

    singleLineBreaksStaysInLet


  // Double line break resets to previous let indent
  // Even when deeply nested
  let anotherFunc =
    doDifferentStuff


  // ### Match
  // Supports nested match expressions and dedenting when default case entered.
  match action with
  | compactCase1 -> result1
  | compactCase2 -> result2
  | multilineCase3 ->
    result3
  | multilineWithCondition4 ->
    when condition ->
    result4
  | nestedMatch ->
    match nested with
    | nestedCase5 ->
      result5
    | _ -> nestedDefaultCase
  | _ -> defaultCase


  // ### Module
  module Example
  let func =
    doSomething

  module Example =
    let func =
      doSomething


  // ### Pipelining
  let func =
    doSomething
    |> andAnotherThing
    |> andOneMoreThing

  // Supports multiline pipeline expressions.
  doSomething
  |>
    if condition then
      doThis
    else
      doThat


  // ### Type (Record, Discriminated Union)
  type SomeRecord = {
    Field1: int
    Field2: string
  }

  let someFunc () =
    {
      Field1 = 1
      Field2 = "something"
    }


  let someRecord = {
    Field1 = 1
    Field2 = "something"
  }


  { someRecord with
      Field1 = 2
  }


  let newRecord = {
    someRecord with
      Field1 = 3
  }
```


## TODO

* Add support for classes and a few other structures.
* Optimise and cleanup code
* Proper support for F# Interactive (.fsx/.fsi) files


## Development

### Minimal `vimrc` for manual testing

* For Neovim, run: `nvim -Nu tests/vimrc`
* For Vim, run: `vim -Nu tests/vimrc`

### Running tests

Run from either PowerShell or Bash.

Syntax: `./test [-v] [-l] [testname]`

* Run all tests in Neovim - `./test`
* Run a single test in Vim - `./test -v let`
* Run a single test with logging - `./test -l let`

