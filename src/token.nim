import os
import docopt

import actions/handle
import config/config_obj
import args/parse   as aparse
import config/parse as cparse

const DOC = """
A command line token reward system manager.

Usage:
  token [-p PAGE]  add     (-r REWARD) [-d DATE] [-m META] <name>...
  token [-p PAGE]  del     [--] [<ID>]
  token [-p PAGE]  export  [-f FORMAT]
  token [-p PAGE] [-c COLOR]  graph
    [<FILTER>] [--before DATE] [--after DATE] [--mode MODE] [--value]
  token [-p PAGE] [-c COLOR]  info [--] [<ID>]
  token [-p PAGE] [-c COLOR]  list
    [<FILTER>] [--before DATE] [--after DATE] [-l LIMIT] [-o OFFSET]
  token [-p PAGE] [-c COLOR]  itable  [-s SUBPAGE]
  token [-p PAGE] [-c COLOR]  [table] [-s SUBPAGE]
  token (-h | --help)
  token --version

Subcommands:
  add                            Add a new token.
  del                            Remove token.
  export                         Export tokens to external format.
  graph                          Make a histogram of token values vs date.
  info                           Show information about token.
  list                           List tokens.
  table                          Show a verbose table of tokens.
  itable                         Show an iconic table of tokens.

Global Options:
  -p PAGE, --page=PAGE           Page number.
  -c COLOR, --color=COLOR        Use colors to format output [default: auto].
                                   By default colorized output will be used
                                   only if stdout is a terminal.
                                   Supported modes: on, off, auto.
  -h --help                      Show this message and exit.
  --version                      Show version and exit.

Filters:
  <FILTER>                       Regular expression to be matched against token
                                   description.
  --after=DATE                   Keep only tokens added after DATE.
                                   Date format: YYYY-MM-DD
  --before=DATE                  Keep only tokens added before DATE.
                                   Date format: YYYY-MM-DD

Command Options:
  -s SUBPAGE, --subpage=SUBPAGE  Subpage number [default: 0].
                                   Last subpage is displayed by default.
  -r REWARD, --reward=REWARD     Reward Value.
  -d DATE, --date=DATE           Date token was earned.
  -m META, --meta=META           Metadata associated with token.
  -l LIMIT, --limit=LIMIT        Number of tokens to display [default: -1].
                                   Use 0 to remove limit, or -1 to limit number
                                   of lines to the screen height.
  -o NUM, --offset=NUM           Display tokens starting with NUM [default: 0].
  -f FORMAT, --format=FORMAT     Format to export tokens to to [default: json].
                                   Supported formats: json.
  --value                        Make a graph of token value, instead of token
                                   number.
  --mode=MODE                    Graph mode [default: day].
                                   Supported modes: day, week, month, year.
"""

proc createDefaultConfig(configFile : string) =
    writefile(
        configFile,
        "tokenDir=~/.token\n" &
        "pageSize=200\n"
    )

proc tryLoadConfig() : config_obj.Config =
    let configFile = joinPath(getHomeDir(), ".tokenrc")

    if not existsFile(configFile):
        write(
            stdout,
            "Configuration file '" & configFile & "' does not exist" &
             ". Create a default one? [y/N]: "
         )

        let answer : string = readLine(stdin)
        if answer notin [ "Y", "y", "Yes", "yes" ]:
            raise newException(IOError, "No ~/.tokenrc config file found")

        createDefaultConfig(configFile)

    return load(configFile)

proc main() =
    const NimblePkgVersion {.strdefine.} : string = ""
    var version = "token " & NimblePkgVersion

    let cmdargs = docopt(DOC, version = version)
    var args    = parseArgs(cmdargs)
    var config  = tryLoadConfig()

    handleAction(args, config)

when isMainModule:
    main()

