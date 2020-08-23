import unittest
import strformat
import sequtils
import strutils

include token/parse

suite "Test Token Parsers":

    let
        testTime1 = initDateTime(1, mJan, 2000, 0, 0, 0)
        testTime2 = initDateTime(2, mJan, 2000, 0, 0, 0)
        testTime3 = initDateTime(3, mJan, 2000, 0, 0, 0)

    template compareTokens(a : Token, b : Token) =
        check(a.date   == b.date)
        check(a.reward == b.reward)
        check(a.descr  == b.descr)
        check(a.meta   == b.meta)

    test "Test Key/Value Parsing":
        let tokenNull = initToken(testTime1, 5, "test", "test_meta")
        var tokenTest = Token(date : testTime1, reward : 1, page : 1, id : 1)

        parseTokenKeyVal(
            tokenTest, KEY_TOKEN_DATE,
            '"' & format(tokenNull.date, TOKEN_DATE_FMT) & '"'
        )
        parseTokenKeyVal(
            tokenTest, KEY_TOKEN_REWARD, '"' & $tokenNull.reward & '"'
        )
        parseTokenKeyVal(
            tokenTest, KEY_TOKEN_DESCR, '"' & $tokenNull.descr & '"'
        )
        parseTokenKeyVal(
            tokenTest, KEY_TOKEN_META, '"' & $tokenNull.meta & '"'
        )

        compareTokens(tokenNull, tokenTest)

    test "Test Full Token Parsing":

        let tokenNull = initToken(testTime1, 5, "test", "test_meta")
        let tokenNullString   = $tokenNull

        var s = newStringStream(tokenNullString)

        var nLinesRead : uint = 0
        var tokenList  : TokenList = @[]

        parseToken(s, nLinesRead, tokenList)

        check(tokenList.len() == 1)
        compareTokens(tokenNull, tokenList[0])

    test "Test Multiple Tokens Parsing":

        let tokensNull = @[
            initToken(testTime1, 1, "test1", "meta1"),
            initToken(testTime2, 2, "test2", "meta2"),
            initToken(testTime3, 3, "test3", "meta3"),
        ]

        var s = newStringStream(
            tokensNull
                .map(proc (x : Token) : string = $x)
                .join("\n")
        )

        var nLinesRead : uint = 0
        var tokenList  : TokenList = @[]

        while not s.atEnd():
            parseToken(s, nLinesRead, tokenList)

        check(tokenList.len() == tokensNull.len())
        compareTokens(tokensNull[0], tokenList[0])
        compareTokens(tokensNull[1], tokenList[1])
        compareTokens(tokensNull[2], tokenList[2])

    test "Test Comment/Blank lines Token Parsing":

        let tokenNull = initToken(testTime1, 5, "test", "test_meta")
        let dateStr   = format(tokenNull.date, TOKEN_DATE_FMT)

        let tokenNullNullStr  = (
            "\n"                                                    &
            "\n"                                                    &
            "# Comment 0\n"                                         &
            "\n"                                                    &
            "\n"                                                    &
            &"{STR_TOKEN_START}\n"                                  &
            "# Comment 1\n"                                         &
            &"  {KEY_TOKEN_DATE}:\"{dateStr}\"\n"                   &
            "# Comment 2\n"                                         &
            "\n"                                                    &
            "\n"                                                    &
            &"    {KEY_TOKEN_REWARD}    : \"{tokenNull.reward}\"\n" &
            "# Comment 3\n"                                         &
            "# Comment 4\n"                                         &
            "# Comment 5\n"                                         &
            &"{KEY_TOKEN_DESCR}         :\"{tokenNull.descr}\"\n"   &
            &"    {KEY_TOKEN_META}   : \"{tokenNull.meta}\"\n"      &
            &"{STR_TOKEN_END}\n"                                    &
            "# Comment 6\n"                                         &
            "# Comment 7\n"                                         &
            "# Comment 8\n"                                         &
            "\n"                                                    &
            "\n"
        )

        var s = newStringStream($tokenNullNullStr)

        var nLinesRead : uint = 0
        var tokenList  : TokenList = @[]

        while not s.atEnd():
            parseToken(s, nLinesRead, tokenList)

        check(tokenList.len() == 1)
        compareTokens(tokenNull, tokenList[0])

