import strformat
import times

import ../../token/token_obj

type
    TextAlign* {.pure.} = enum
        Left, Right, Center, Floating

    SizePolicy* {.pure.} = enum
        Fixed, Stretch

    ValueSpec* = object
        align*      : TextAlign
        getValue*   : proc (token : Token) : string
        name*       : string
        marginSize* : int
        sizePolicy* : SizePolicy

let
    VALUE_SPEC_ID* = ValueSpec(
        align      : TextAlign.Right,
        getValue   : proc (token : Token) : string = $token.id,
        name       : "ID",
        marginSize : 1,
        sizePolicy : SizePolicy.Fixed,
    )

    VALUE_SPEC_PAGE* = ValueSpec(
        align      : TextAlign.Right,
        getValue   : proc (token : Token) : string = $token.page,
        name       : "Page",
        marginSize : 1,
        sizePolicy : SizePolicy.Fixed,
    )

    VALUE_SPEC_PAGEID* = ValueSpec(
        align      : TextAlign.Left,
        getValue   :
            proc (token : Token) : string = fmt"{token.page}.{token.id}",
        name       : "Page-ID",
        marginSize : 1,
        sizePolicy : SizePolicy.Fixed,
    )

    VALUE_SPEC_REWARD* = ValueSpec(
        align      : TextAlign.Center,
        getValue   : proc (token : Token) : string = $token.reward,
        name       : "Reward",
        marginSize : 1,
        sizePolicy : SizePolicy.Fixed,
    )

    VALUE_SPEC_DESCR* = ValueSpec(
        align      : TextAlign.Left,
        getValue   : proc (token : Token) : string = token.descr,
        name       : "Description",
        marginSize : 1,
        sizePolicy : SizePolicy.Stretch,
    )

    VALUE_SPEC_DATE* = ValueSpec(
        align      : TextAlign.Right,
        getValue   :
            proc (token : Token) : string =
                return format(token.date, "yyyy-MM-dd"),
        name       : "Date",
        marginSize : 1,
        sizePolicy : SizePolicy.Fixed,
    )

    VALUE_SPEC_TIME* = ValueSpec(
        align      : TextAlign.Right,
        getValue   :
            proc (token : Token) : string = return format(token.date, "HH:mm"),
        name       : "Time",
        marginSize : 1,
        sizePolicy : SizePolicy.Fixed,
    )

    VALUE_SPEC_META* = ValueSpec(
        align      : TextAlign.Left,
        getValue   :
            proc (token : Token) : string =
                return if len(token.meta) > 0: "true" else: "false",
        name       : "Meta",
        marginSize : 1,
        sizePolicy : SizePolicy.Fixed,
    )

    VALUE_SPEC_INFO_DATE* = ValueSpec(
        align      : TextAlign.Right,
        getValue   :
            proc (token : Token) : string =
                return format(token.date, "ddd yyyy-MM-dd"),
        name       : "Date",
        marginSize : 1,
        sizePolicy : SizePolicy.Fixed,
    )

    VALUE_SPEC_INFO_TIME* = ValueSpec(
        align      : TextAlign.Right,
        getValue   :
            proc (token : Token) : string =
                return format(token.date, "HH:mm:ss"),
        name       : "Time",
        marginSize : 1,
        sizePolicy : SizePolicy.Fixed,
    )

    VALUE_SPEC_INFO_META* = ValueSpec(
        align      : TextAlign.Floating,
        getValue   : proc (token : Token) : string = return token.meta,
        name       : "Meta Info",
        marginSize : 1,
        sizePolicy : SizePolicy.Fixed,
    )

