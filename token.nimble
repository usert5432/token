# Package
version     = "0.1.1"
author      = "Dmitrii Torbunov"
description = "A command line token reward system manager"
license     = "ISC"

# Files
bin     = @[ "token" ]
srcDir  = "src"
skipExt = @[ "nim" ]

# Deps
requires "nim >= 0.10.0"
requires "docopt"

task test, "Runs the test suite":
    exec "nim c -r tests/run_tests"

