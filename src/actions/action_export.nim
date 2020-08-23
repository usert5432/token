import json
import strformat
import times

import ../args/args_obj
import ../config/config_obj
import ../token/token_obj
import ../token/token_dir
import ../token/token_list
import ../token/token_page

proc sanitizeArgs(args : Args) =
    assert(args.kind == ArgsKind.Export)

    if not (args.format in @[ "json" ]):
        raise newException(ValueError, fmt"Unknown format {args.format}")

proc `%`(o : DateTime) : JsonNode =
    JsonNode(kind : JString, str : format(o, TOKEN_DATE_FMT))

proc exportTokenList(tokenList : TokenList, format : string) : string =
    case format:
    of "json":
        result = pretty(%*tokenList)
    else:
        raise newException(ValueError, fmt"Unknown format {format}")

proc handleActionExport*(args : Args, config : Config) =
    sanitizeArgs(args)

    var tokenList : TokenList = @[]

    if args.page == 0:
        loadAll(tokenList, config.rootDir)
    else:
        args.page = loadPage(tokenList, config.rootDir, args.page).pageNum

    echo exportTokenList(tokenList, args.format)

