import logging
import strutils

import ./funcs
import ../args/args_obj
import ../config/config_obj
import ../token/token_list
import ../token/token_obj
import ../token/token_page

proc sanitizeArgs(args : Args) =
    assert(args.kind == ArgsKind.Del)

    if args.id == 0:
        raise newException(
            ValueError, "Must supply nonzero ID of the token to delete"
        )

proc askConfirmation(msg : string) : bool =
    write(stdout, msg)

    let answer : string = readLine(stdin)

    if answer in [ "Y", "y", "Yes", "yes" ]:
        return true

    return false

proc askTokenRemovalConfirmation(token : Token) : bool =
    let askMsg : string = join(
        [
            "This operation will remove the following token:\n", $token,
            "Confirm [y/N]: "
        ],
        "\n"
    )

    return askConfirmation(askMsg)

proc handleActionDel*(args : Args, config : Config) =
    sanitizeArgs(args)

    var tokenList : TokenList = @[]

    if args.page == 0:
        args.page = -1

    args.page = loadPage(tokenList, config.rootDir, args.page).pageNum
    let index = getTokenIndex(args.id, tokenList)

    if askTokenRemovalConfirmation(tokenList[index]):
        tokenList.delete(index)
        savePage(tokenList, config.rootDir, args.page)
        info("Removed")
    else:
        warn("Aborting")

