import options
import strutils
import strformat
import tables
import terminal
import times

import docopt
from args_obj import Args, ArgsKind

from ../token/token_obj  import TOKEN_DATE_FMT
from ../token/token_list import TokenFilter

const
    POSSIBLE_DATE_FORMATS = [
        TOKEN_DATE_FMT,
        "YYYY-MM-dd",
        "YYYY-MM-dd'T'HH",
        "YYYY-MM-dd'T'HH:mm",
        "YYYY-MM-dd'T'HH:mm:ss",
        "YYYY-MM-dd'T'HH:mm:sszzz",
        "YYYY-MM-dd'_'HH",
        "YYYY-MM-dd'_'HH:mm",
        "YYYY-MM-dd'_'HH:mm:ss",
        "YYYY-MM-dd'_'HH:mm:ss'_'zzz",
    ]

proc parseTokenTime*(date : string) : DateTime =

    if (date.len() == 0) or (date == "nil"):
        return now()

    for dateFmt in POSSIBLE_DATE_FORMATS:
        try:
            result = parse(date, dateFmt)
            return
        except TimeParseError, Defect:
            continue

    raise newException(TimeParseError, fmt"Failed to parse time: '{date}'")

proc parseID(cmdargs : Table[string, Value]) :
    tuple[id : int, page : Option[int]] =

    if not cmdargs["<ID>"]:
        return (id : -1, page : none(int))

    let tokens = split($cmdargs["<ID>"], '.')
    if len(tokens) > 2:
        raise newException(
            ValueError,
            fmt"Failed to parse id {tokens}"
        )

    if len(tokens) == 2:
        return (
            id : parseInt(tokens[1]), page  : some(parseInt(tokens[0]))
        )

    return (id : parseInt(tokens[0]), page : none(int))

proc parseTokenFilter(cmdargs : Table[string, Value]) : TokenFilter =

    if cmdargs["<FILTER>"]:
        result.regexp = $cmdargs["<FILTER>"]

    if cmdargs["--after"]:
        result.firstDate = some(parseTokenTime($cmdargs["--after"]))

    if cmdargs["--before"]:
        result.lastDate = some(parseTokenTime($cmdargs["--before"]))

proc parseUseColor(cmdargs : Table[string, Value]) : bool =
    result = isatty(stdout)

    if not cmdargs["--color"]:
        return

    let mode = $cmdargs["--color"]

    case mode
    of "auto":
        return
    of "off":
        return false
    of "on":
        return true
    else:
        raise newException(
            ValueError, fmt"Failed to parse color mode: '{mode}'"
        )

proc parseArgs*(cmdargs : Table[string, Value]) : Args =

    if cmdargs["add"]:
        result = Args(
            kind   : ArgsKind.Add,
            descr  : join(@(cmdargs["<name>"]), " "),
            reward : parseInt($cmdargs["--reward"]),
            date   : parseTokenTime($cmdargs["--date"]),
        )

        if cmdargs["--meta"]:
            result.meta = $cmdargs["--meta"]

    elif cmdargs["del"]:
        let pageID = parseID(cmdargs)
        result = Args(kind : ArgsKind.Del, id : pageID.id)

        if pageID.page.isSome():
            result.page = pageID.page.get()

    elif cmdargs["export"]:
        result = Args(kind : ArgsKind.Export, format : $cmdargs["--format"])

    elif cmdargs["graph"]:
        result = Args(
            kind   : ArgsKind.Graph,
            mode   : $cmdargs["--mode"],
            value  : cmdargs["--value"].to_bool(),
            filter : parseTokenFilter(cmdargs),
        )

    elif cmdargs["info"]:
        let pageID = parseID(cmdargs)
        result = Args(kind : ArgsKind.Info, id : pageID.id)

        if pageID.page.isSome():
            result.page = pageID.page.get()

    elif cmdargs["list"]:
        result = Args(
            kind       : ArgsKind.List,
            limit      : parseInt($cmdargs["--limit"]),
            offset     : parseInt($cmdargs["--offset"]),
            listFilter : parseTokenFilter(cmdargs),
        )

    elif cmdargs["itable"]:
        result = Args(
            kind    : ArgsKind.Table,
            icons   : true,
            subpage : parseInt($cmdargs["--subpage"])
        )

    else:
        result = Args(
            kind    : ArgsKind.Table,
            icons   : false,
            subpage : parseInt($cmdargs["--subpage"])
        )

    if cmdargs["--page"]:
        result.page = parseInt($cmdargs["--page"])

    result.useColor = parseUseColor(cmdargs)

