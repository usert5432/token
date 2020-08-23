import math
import strutils
import strformat
import terminal

import ../args/args_obj
import ../config/config_obj
import ../token/token_list
import ../token/token_page
import ../printers/table/icon_table
import ../printers/table/text_table
import ../printers/table/table_funcs
import ../printers/table/table_spec

const
    N_LINES_AROUND_TABLE : int = 3
    #   +1 -- empty line before
    #   +1 -- empty line after
    #   +1 -- space for cmd prompt

proc getScreenShape() : tuple[x : int, y : int] =

    let termWidth  = terminalWidth()
    let termHeight = terminalHeight()

    let tableWidth  = termWidth
    let tableHeight = termHeight - N_LINES_AROUND_TABLE

    return (tableWidth, tableHeight)

proc getTableSpec(args : Args) : TableSpec =

    if args.icons:
        result = iconTableSpec
    else:
        result = textTableSpec

    let screenShape = getScreenShape()
    result.inferTableShape(screenShape.x, screenShape.y)

proc getSubpageIndex(subpage : int, nFilled : int, nSubpages : int) :
    int =

    if subpage == 0:
        result = max(nFilled - 1, 0)
    elif subpage > 0:
        result = subpage - 1
    else:
        result = nSubpages + subpage

    if (result >= nSubpages) or (result < 0):
        raise newException(
            RangeError,
            fmt"Subpage index '{result}' is out of range [0, {nSubpages})"
        )

proc printTableBody(
    tableSpec : TableSpec, tokenList : TokenList, cellsPerScreen : int,
    subpageIdx : int, args : Args, config : Config
) : seq[string] =

    if args.icons:
        return printIconTable(
            tableSpec, tokenList, cellsPerScreen * subpageIdx,
            config.pageSize, config.cmap, args.useColor
        )
    else:
        return printTextTable(
            tableSpec, tokenList, cellsPerScreen * subpageIdx,
            config.pageSize, config.cmap, args.useColor
        )

proc printTableSummary(
    tableSpec : TableSpec, tokenList : TokenList, cellsPerScreen : int,
    subpageIdx : int, nSubpages : int, args : Args, config : Config
) : string =

    let entriesStart = cellsPerScreen * subpageIdx + 1;
    let entriesEnd   = min(
        config.pageSize, cellsPerScreen * (subpageIdx + 1) + 1
    )

    let nTokens   = tokenList.len()
    let fillRatio = 100 * nTokens / config.pageSize

    return (
        fmt"Page: {args.page}. Subpage[{tableSpec.ncols}x{tableSpec.nRows}]" &
        fmt": {subpageIdx+1} / {nSubpages}."            &
        fmt" Entries: {entriesStart}-{entriesEnd}."     &
        fmt" Completeness: {nTokens} / {config.pageSize} ({fillRatio} %)"
    )

proc handleActionTable*(args : Args, config : Config) =

    var tokenList : TokenList = @[]

    if args.page == 0:
        args.page = -1

    args.page     = loadPage(tokenList, config.rootDir, args.page).pageNum
    let tableSpec = getTableSpec(args)

    let cellsPerScreen  = tableSpec.nRows * tableSpec.nCols
    let nSubpages       = toInt(ceil(config.pageSize / cellsPerScreen))
    let nFilledSubpages = toInt(ceil(len(tokenList) / cellsPerScreen))

    let subpageIdx = getSubpageIndex(args.subpage, nFilledSubpages, nSubpages)

    let tableBody = printTableBody(
        tableSpec, tokenList, cellsPerScreen, subpageIdx, args, config
    )
    let tableSummary = printTableSummary(
        tableSpec, tokenList, cellsPerScreen, subpageIdx, nSubpages,
        args, config
    )

    echo join(tableBody, "\n")
    echo tableSummary

