import times
import strutils
import strformat
import streams

import token_obj
import token_list

type
    TokenParseState {.pure.} = enum
        awaitingStart, parsingToken

proc parseTokenKeyVal(token : var Token, key : string, val : string) =

    # val is supposed to be a double quoted value

    if (len(val) < 2) or (val[0] != '"') or (val[^1] != '"'):
        raise newException(ValueError, fmt"Malformed value '{val}'")

    var val = val[1..^2]

    case key
    of KEY_TOKEN_DATE:
        token.date = parse(val, TOKEN_DATE_FMT)
    of KEY_TOKEN_REWARD:
        token.reward = parseInt(val)
    of KEY_TOKEN_DESCR:
        token.descr = val
    of KEY_TOKEN_META:
        token.meta = val
    else:
        raise newException(ValueError, fmt"Unknown token key '{key}'")

proc parseTokenBodyLine(token : var Token, line : string) =

    let keyVal = split(line, ':', maxsplit = 1)

    if len(keyVal) != 2:
        raise newException(
            ValueError, fmt"Failed to split '{line}' into key/val pair"
        )

    let key = strip(keyVal[0])
    var val = strip(keyVal[1])

    parseTokenKeyVal(token, key, val)

proc parseToken*(
    s : Stream, nLinesRead : var uint, tokenList : var TokenList
) =
    var token = initToken(
        initDateTime(1, mJan, 2000, 0, 0, 0), 1, "", ""
    )

    var parseState = TokenParseState.awaitingStart

    var line : string

    while s.readLine(line):
        nLinesRead += 1

        if (line.len() == 0) or line.startsWith('#'):
            continue

        case parseState:
        of TokenParseState.awaitingStart:
            if line == STR_TOKEN_START:
                parseState = TokenParseState.parsingToken
            else:
                raise newException(
                    ValueError, fmt"Found data outside of token: {line}"
                )

        of TokenParseState.parsingToken:
            if line == STR_TOKEN_START:
                raise newException(
                    ValueError, "Found token start before previous terminated"
                )
            elif line == STR_TOKEN_END:
                tokenList.add(token)
                return
            else:
                parseTokenBodyLine(token, line)

proc loadTokens*(tokenList : var TokenList, filename : string) : int =
    result = 0

    let s : FileStream = openFileStream(filename, fmRead)
    var nLinesRead : uint = 0

    while not s.atEnd():
        try:
            parseToken(s, nLinesRead, tokenList)
            result += 1
        except IOError as e:
            raise newException(
                IOError,
                "Failed to parse token at line {nLinesRead}: " & e.msg
            )

    s.close()


