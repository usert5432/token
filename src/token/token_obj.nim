import streams
import strformat
import times

const
    STR_TOKEN_START*  : string = "Token {"
    STR_TOKEN_END*    : string = "}"
    TOKEN_DATE_FMT*   : string = "yyyy-MM-dd\'T\'HH:mm:sszzz"
    KEY_TOKEN_DATE*   : string = "date"
    KEY_TOKEN_REWARD* : string = "reward"
    KEY_TOKEN_DESCR*  : string = "descr"
    KEY_TOKEN_META*   : string = "meta"

type
    Token* = object
        date*   : DateTime
        reward* : range[1..10]
        descr*  : string
        meta*   : string
        page*   : Positive
        id*     : Positive


proc initToken*(
    date : DateTime, reward : int, descr : string, meta : string = ""
) : Token =

    return Token(
        date   : date,
        reward : reward,
        descr  : descr,
        meta   : meta,
        page   : 1,
        id     : 1,
    )

proc `$`*(token : Token) : string =
    let dateStr = format(token.date, TOKEN_DATE_FMT)

    result  = &"{STR_TOKEN_START}\n"
    result &= &"    {KEY_TOKEN_DATE}   : \"{dateStr}\"\n"
    result &= &"    {KEY_TOKEN_REWARD} : \"{token.reward}\"\n"
    result &= &"    {KEY_TOKEN_DESCR}  : \"{token.descr}\"\n"
    result &= &"    {KEY_TOKEN_META}   : \"{token.meta}\"\n"
    result &= &"{STR_TOKEN_END}\n"

proc save*(token : Token, s : Stream) =
    s.write($token)

