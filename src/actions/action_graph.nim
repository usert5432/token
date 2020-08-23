import times
import math
import sequtils
import strformat
import terminal

import ../args/args_obj
import ../config/config_obj
import ../token/token_dir
import ../token/token_list
import ../token/token_page
import ../printers/graph/graph
import ../printers/graph/hist_obj

proc sanitizeArgs(args : Args) =
    assert(args.kind == ArgsKind.Graph)

proc parseGraphMode(mode : string) : GraphMode =
    case mode
    of "day":
        return GraphMode.Day
    of "week":
        return GraphMode.Week
    of "month":
        return GraphMode.Month
    of "year":
        return GraphMode.Year
    else:
        raise newException(
            ValueError, fmt"Failed to parse graph mode {mode}"
        )

proc printSummaryLine(hist : Hist, filter : TokenFilter) =
    var output : string

    if hist.valueHist:
        output = "Value histogram."
    else:
        output = "Token histogram."

    let total = sum(map(hist.bins, proc (bin : HistBin) : uint = bin.height))
    let avr   = float(total) / float(len(hist.bins))

    output &= fmt" Mode: {hist.mode}. Total: {total}. Mean: {avr:.1f}."
    output &= '\n'

    if len(filter.regexp) > 0:
        output &= fmt"Filter: '{filter.regexp}'. "

    output &= ("Start Date: " & format(hist.firstDate, "yyyy-MM-dd'.'"))
    output &= (" End Date: "   & format(hist.lastDate,  "yyyy-MM-dd'.'"))

    echo output

proc handleActionGraph*(args : Args, config : Config) =
    sanitizeArgs(args)

    let graphMode = parseGraphMode(args.mode)

    var tokenList : TokenList = @[]

    if args.page == 0:
        loadAll(tokenList, config.rootDir)
    else:
        args.page = loadPage(tokenList, config.rootDir, args.page).pageNum

    let filteredTokenList = filterTokenList(tokenList, args.filter)

    let hist  = constructHist(filteredTokenList, graphMode, args.value)
    let termW = terminalWidth()
    let graph = printGraph(hist, graphMode, termW, config.cmap, args.useColor)

    for line in graph:
        echo line

    printSummaryLine(hist, args.filter)

