# Cross-platform, Tested F# Indent and Syntax For Vim

![tests](https://github.com/PhilT/vim-fsharp/actions/workflows/test.yml/badge.svg)

## Status

* **Indent:** Working
* **Syntax:** Modified from [ionide-vim](https://github.com/ionide/Ionide-vim)
  with some minor fixes
* **Plugin:** None (I recommend Neovim 0.8 with [FsAutoComplete](https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#fsautocomplete))

This plugin is currently focused on providing better indent support in F#.
If you find any problems, raise an issue and we'll work out a solution
together.


## Why?

* [vim-fsharp](https://github.com/fsharp/vim-fsharp) hasn't been updated for a
  few years and also contains old versions of FsAutoComplete which don't really
  work (at least for my setup)
* Language features can be provided by an LSP (e.g. Neovim 0.8's [built-in LSP client](https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#fsautocomplete)
  or [coc-fsharp](https://github.com/coc-extensions/coc-fsharp))
* Enhancements to indent rules can provide a better experience
* Other plugins don't improve the basic syntax and indent behaviour and seem to
  have issues on Windows platforms


## Features

* A lightweight indenter written in pure Vimscript.
* Robust indentation support
* 2 line-breaks end function
* Reformatting support (providing above 2 blank lines rule is followed). For
  something full-featured, look at [Fantomas](https://github.com/fsprojects/fantomas)
  also included in [FsAutoComplete](https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#fsautocomplete)
* Automated tests - Rules can be added without breaking existing functionality
* Developed on Windows 10/11 and Ubuntu 20.04 with Neovim 0.8
* Tested in Vim and Neovim stable (Neovim nightly should okay too)
* Tested on Windows 10/11 and Ubuntu 20.04


## Limitations

Sometimes the indenter won't immediately indent something (e.g. record keys).
Just keep typing and it should figure out what you want to do.

This plugin is tested with the following vim settings:

```vim
set shiftwidth=2
set backspace=2
set tabstop=2
set softtabstop=2
set expandtab
filetype plugin indent on
syntax enable
```

This plugin probably doesn't support deeply nested code. Then
again, you probably shouldn't be writing deeply nested code.
Still, if you think you have a valid case, raise an issue and
I'll be happy to take a look.


## Installation

Add to your plugin manager:

[vim-plug](https://github.com/junegunn/vim-plug)
```
Plug 'PhilT/vim-fsharp'
```

[Paq](https://github.com/savq/paq-nvim) (Neovim Lua)
```lua
paq {'PhilT/vim-fsharp'}
```

If you use [vim-polyglot](https://github.com/sheerun/vim-polyglot) be sure to
load **vim-fsharp** before it or `let g:polyglot_disabled = ['fsharp']` before
loading plugins.

## Works with

Neovim 0.8's LSP client with nvim-lspconfig provides out of the box
support for many languages. I've just added support for F# using the awesome
FsAutoComplete library.

* [Neovim 0.8](https://github.com/neovim/neovim)
* [F# plug in nvim-lspconfig](https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#fsautocomplete)
* [FsAutoComplete](https://github.com/fsharp/FsAutoComplete)


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


  // ### Exceptions
  let handleExceptions func args =
    try
      func args
      someOtherStuff
    with
      | MyException(str) -> printfn "MyError: %s" str
      | MyTupleException(str, i) -> printfn "MyTupleError: %s, %d" str i


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
  let func () =
    doSomething


  module ThisWillContainTheRestOfTheCode =
    let func () =
      doSomething


    // ### Pipelining
    let func () =
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
5. Add to `tests/integration.vader` [optional]
6. Add to `tests/readme.vader`
7. Add to `README.md`
8. Add to `tests/reformat.vader`

### Minimal `vimrc` for manual testing

* For Neovim, run: `nvim -Nu tests/vimrc`
* For Vim, run: `vim -Nu tests/vimrc`

### Running tests

Install vader-vim with `./install-vader` (this will install into ./vader.vim/)

Run from either PowerShell or Bash.

Syntax: `./test [-v] [-l] [testname]`

* Run all tests in Neovim - `./test`
* Run a single test in Vim - `./test -v let`
* Run a single test with logging - `./test -l let`

