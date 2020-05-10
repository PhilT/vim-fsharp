# An Opinionated, Cross-platform F# Indent and Syntax plugin for Vim

[![Build Status](https://travis-ci.org/PhilT/vim-fs.svg?branch=master)](https://travis-ci.org/PhilT/vim-fs)

## Status

* **Indent:** Mostly complete as of May 2020
* **Syntax:** Copied from [ionide-vim](https://github.com/ionide/Ionide-vim)
  with some minor fixes
* **Plugin:** None

This plugin is currently focused on providing better indent support in F#.
If you find any problems, raise an issue with some example code and providing
it doesn't conflict with other rules, I'll add it. Otherwise, we'll have to work
out a compromise.


## Why?

* [vim-fsharp](https://github.com/fsharp/vim-fsharp) hasn't been touched in a
  couple of years and `indent/` is 4 years old. It appears to have been
  abandoned.
* Language features can be more easily provided by an LSP (e.g.
  [coc-fsharp](https://github.com/coc-extensions/coc-fsharp))
* Enhancements to indent rules can provide a better experience
* Other plugins don't improve the basic syntax and indent behaviour and seem to
  have issues on Windows platforms

## Features

* Robust indentation support
* 2 line breaks ends function
* Reformating support (providing above 2 blank lines rule is followed)
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


  // ### Classes
  // Indents members, including default and override
  type MyBase() =
    member _.Func1 x =
      x + 1

    default _.Func2 y =
      y + 2


  type MyDerived() =
    override _.Func1 x =
      x + 10


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

* Optimise and cleanup code
* Check support for F# Interactive (.fsx/.fsi) files
* Ensure [F# formatting conventions](https://github.com/fsprojects/fantomas/blob/master/docs/FormattingConventions.md)
  are followed as much as possible


## Development

### Workflow

1. Add a test in `tests/`
2. Add the minimal code to get it working
3. Refactor
4. Repeat steps 1-3 as required
5. Add to `tests/integration.vader`
6. Add to `README.md`
7. Add to `tests/readme.vader`

### Minimal `vimrc` for manual testing

* For Neovim, run: `nvim -Nu tests/vimrc`
* For Vim, run: `vim -Nu tests/vimrc`

### Running tests

Run from either PowerShell or Bash.

Syntax: `./test [-v] [-l] [testname]`

* Run all tests in Neovim - `./test`
* Run a single test in Vim - `./test -v let`
* Run a single test with logging - `./test -l let`

