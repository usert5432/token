import strutils
import strformat
import terminal

import ../args/args_obj
import ../config/config_obj
import ../token/token_dir
import ../token/token_list
import ../token/token_obj
import ../token/token_page
import ../printers/list/list
import ../printers/value_spec/value_spec
import ../printers/list/list_spec

const
    N_LINES_AROUND_LIST : int = 5
    #   +1 -- empty line before
    #   +1 -- table header
    #   +1 -- empty line after
    #   +1 -- summary line
    #   +1 -- space for cmd prompt

let LIST_SPEC : ListSpec = @[
    VALUE_SPEC_DATE, VALUE_SPEC_TIME,
    VALUE_SPEC_REWARD, VALUE_SPEC_DESCR, VALUE_SPEC_META
]

proc getListHeight(args : Args, tokenList : TokenList) : int =

    if args.limit == 0:
        return tokenList.len()
    elif args.limit == -1:
        let termHeight = terminalHeight()
        return termHeight - N_LINES_AROUND_LIST
    else:
        return args.limit

proc getListOffset(args : Args, tokenList : TokenList, listHeight : int) :
    int =

    if args.offset == 0:
        return max(0, len(tokenList) - listHeight)
    else:
        return args.offset - 1

proc getSinglePageListSummary(
    args : Args, config : Config, startIdx : int, endIdx : int,
    tokenList : TokenList
) : string =

    let nTokens   = tokenList.len()
    let fillRatio = 100 * nTokens / config.pageSize

    return (
        fmt"Page: {args.page}. Entries: {startIdx + 1}-{endIdx + 1}. " &
        fmt"Completeness: {nTokens} / {config.pageSize} ({fillRatio} %)"
    )

proc getMultiPageListSummary(
    args : Args, config : Config, startIdx : int, endIdx : int,
    tokenList : TokenList
) : string =

    let shown = endIdx - startIdx + 1

    if len(tokenList) == 0:
        return fmt" Shown {shown} token(s)."

    let firstToken = tokenList[startIdx]
    let lastToken  = tokenList[endIdx]

    return (
        fmt"Range: {firstToken.page}.{firstToken.id}" &
        fmt" - {lastToken.page}.{lastToken.id}"       &
        fmt" : {shown} token(s)."
    )

proc getListBody(
    tokenList : TokenList, columns : ListSpec, args : Args, config : Config
) : (seq[string], int, int) =

    let screenCols = terminalWidth()
    let listHeight = getListHeight(args, tokenList)
    let offset     = getListOffset(args, tokenList, listHeight)

    let startIdx = offset
    let endIdx   = min(offset + listHeight, tokenList.len()) - 1

    return (
        printList(
            tokenList[startIdx..endIdx], columns, screenCols, config.cmap,
            args.useColor
        ),
        startIdx, endIdx
    )

proc printListWithSummary(body : seq[string], summary : string) =
    echo ""
    echo join(body, "\n")
    echo ""
    echo summary

proc handleSinglePageActionList*(args : Args, config : Config) =

    var tokenList : TokenList = @[]
    args.page = loadPage(tokenList, config.rootDir, args.page).pageNum
    let filteredTokenList = filterTokenList(tokenList, args.listFilter)

    let columns = @[ VALUE_SPEC_ID ] & LIST_SPEC

    let (listBody, startIdx, endIdx) = getListBody(
        filteredTokenList, columns, args, config
    )

    let listSummary = getSinglePageListSummary(
        args, config, startIdx, endIdx, filteredTokenList
    )

    printListWithSummary(listBody, listSummary)

proc handleMultiPageActionList*(args : Args, config : Config) =

    var tokenList : TokenList = @[]
    loadAll(tokenList, config.rootDir)
    let filteredTokenList = filterTokenList(tokenList, args.listFilter)

    let columns = @[ VALUE_SPEC_PAGEID ] & LIST_SPEC

    let (listBody, startIdx, endIdx) = getListBody(
        filteredTokenList, columns, args, config
    )
    let listSummary = getMultiPageListSummary(
        args, config, startIdx, endIdx, filteredTokenList
    )

    printListWithSummary(listBody, listSummary)

proc handleActionList*(args : Args, config : Config) =

    if args.page == 0:
        handleMultiPageActionList(args, config)
    else:
        handleSinglePageActionList(args, config)

