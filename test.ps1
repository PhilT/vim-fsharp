Param([Switch]$log, [Switch]$vim)
$test = $args[0]

#$test = 'reformat'
#$log = $true

if ($vim) {
  $vimcmd = "vim"
} else {
  $vimcmd = "nvim"
}

if ($log) {
  $env:VIM_FS_VERBOSE = "true"
  $verbose = "-V1"
} else {
  $env:VIM_FS_VERBOSE = "false"
  $verbose = ""
}

if ($test) {
  $tests = "tests/$test.vader"
} else {
  $tests = "tests/*.vader"
}

& $vimcmd "-Es" $verbose "-Nu" "tests/vimrc" "-c" "Vader! $tests" > $null


