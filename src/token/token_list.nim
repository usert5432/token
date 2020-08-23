import options
import re
import sequtils
import streams
import times

from algorithm import SortOrder, Ascending, sort
import token_obj

type
    TokenList* = seq[Token]

    TokenFilter* = tuple[
        regexp    : string,
        firstDate : Option[DateTime],
        lastDate  : Option[DateTime],
    ]

proc save*(tokenList : TokenList, filename : string) =
    let s : FileStream = openFileStream(filename, fmWrite)

    try:
        for token in tokenList:
            token.save(s)
    finally:
        close(s)

proc sort*(tokenList : var TokenList, order : SortOrder = Ascending) =
    algorithm.sort(
        tokenList,
        proc (a, b : Token) : int = cmp(a.date, b.date),
        order
    )

proc match(token : Token, regexp : Option[Regex], filter : TokenFilter) :
    bool =

    if (filter.firstDate.isSome()) and (filter.firstDate.get() > token.date):
        return false

    if (filter.lastDate.isSome()) and (filter.lastDate.get() < token.date):
        return false

    if regexp.isSome():
        return match(token.descr, regexp.get())

    return true

proc filterTokenList*(tokenList : TokenList, filter : TokenFilter) :
    TokenList =

    var regexp : Option[Regex]

    if len(filter.regexp) > 0:
        regexp = some(re(filter.regexp))

    return sequtils.filter(
        tokenList, proc (token : Token) : bool =
            match(token, regexp, filter)
    )

