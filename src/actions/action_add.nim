import logging
import strformat

import ../args/args_obj
import ../config/config_obj
import ../token/token_list
import ../token/token_obj
import ../token/token_page

proc sanitizeArgs(args : Args) =
    assert(args.kind == ArgsKind.Add)

    if (args.reward < 1) or (args.reward > 10):
        raise newException(
            ValueError,
            fmt"Reward '{args.reward}' is out of range: [1, 10]"
        )

    if args.descr.len() == 0:
        raise newException(ValueError, "No description provided")

proc handleActionAdd*(args : Args, config : Config) =

    sanitizeArgs(args)

    var tokenList : TokenList = @[]

    if args.page != 0:
        args.page = loadPage(tokenList, config.rootDir, args.page).pageNum

        if tokenList.len() >= config.pageSize:
            warn(fmt"Adding token to page {args.page} despite page being full")
    else:
        args.page = loadPage(tokenList, config.rootDir, -1).pageNum
        if tokenList.len() >= config.pageSize:
            info(fmt"Page '{args.page}' completed. Starting new page")
            tokenList = @[]
            args.page += 1

    tokenList.add(initToken(args.date, args.reward, args.descr, args.meta))
    savePage(tokenList, config.rootDir, args.page)

