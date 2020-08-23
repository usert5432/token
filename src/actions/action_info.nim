import strutils
import terminal

import ./funcs
import ../args/args_obj
import ../config/config_obj
import ../token/token_list
import ../token/token_page
import ../printers/info/info
import ../printers/value_spec/value_spec

let INFO_SPEC : InfoSpec = @[
    VALUE_SPEC_PAGE, VALUE_SPEC_ID,
    VALUE_SPEC_INFO_DATE, VALUE_SPEC_INFO_TIME,
    VALUE_SPEC_REWARD, VALUE_SPEC_DESCR, VALUE_SPEC_INFO_META
]

proc handleActionInfo*(args : Args, config : Config) =

    var tokenList : TokenList = @[]

    if args.page == 0:
        args.page = -1

    args.page = loadPage(tokenList, config.rootDir, args.page).pageNum

    let screenWidth = terminalWidth()
    let index       = getTokenIndex(args.id, tokenList)

    let res = printInfo(
        tokenList[index], INFO_SPEC, screenWidth, config.cmap, args.useColor
    )
    echo "\n" & join(res, "\n") & "\n"

