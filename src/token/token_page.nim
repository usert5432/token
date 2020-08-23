from algorithm import sort
import logging
import os
import streams
import strformat
import strutils
import times

import parse
import token_list
import token_obj

type
    TokenPage* = tuple[pageNum : Positive, path : string]
const
    TOKEN_PAGE_BASENAME* = "page"
    TOKEN_PAGE_EXT*      = "token"
    TOKEN_DIR_DATE_FMT*  = "YYYY"

proc getTokenPageFileName*(
    date : DateTime, rootDir : string, pageNum : Positive
) : string =

    let dirName = joinPath([ rootDir, format(date, TOKEN_DIR_DATE_FMT) ])
    createDir(dirName)

    result = joinPath(
        dirName, fmt"{TOKEN_PAGE_BASENAME}-{pageNum}.{TOKEN_PAGE_EXT}"
    )

proc createFirstPage(rootDir : string) : TokenPage =
    let pageNum       : Positive = 1
    let firstPagePath : string = getTokenPageFileName(now(), rootDir, pageNum)

    var s = openFileStream(firstPagePath, fmAppend)
    s.close()

    return (pageNum : pageNum, path : firstPagePath)

proc listTokenPages*(rootDir : string) : seq[TokenPage] =

    result = @[]

    let pageGlob = joinPath([
        rootDir, "*", fmt"{TOKEN_PAGE_BASENAME}-*.{TOKEN_PAGE_EXT}"
    ])

    for x in walkFiles(pageGlob):
        let (_, name, _) = splitFile(x)

        let pageNumStr = name[(len(TOKEN_PAGE_BASENAME) + 1)..^1]
        var pageNum : Positive = 1

        try:
            pageNum = parseUInt(pageNumStr)
        except ValueError:
            warn(fmt"Failed to parse page number {pageNumStr}")
            continue

        result.add((pageNum : pageNum, path : x))

    if len(result) == 0:
        result.add(createFirstPage(rootDir))

    sort(
        result, proc (a, b : TokenPage) : int = cmp(a.pageNum, b.pageNum)
    )

proc getPageWithNum*(rootDir : string, pageNum : int) : TokenPage =
    let pages : seq[TokenPage] = listTokenPages(rootDir)

    var resolvedPageNum : Positive

    if pageNum >= 0:
        resolvedPageNum = pageNum
    else:
        let lastPageNum = pages[^1].pageNum

        if lastPageNum < abs(pageNum):
            raise newException(
                ValueError,
                fmt"Page '{pageNum}' is outside of range: 1-{lastPageNum}"
            )

        resolvedPageNum = lastPageNum + 1 + pageNum

    for page in pages:
        if page.pageNum == resolvedPageNum:
            return page

    raise newException(
        ValueError, fmt"Page: '{pageNum}' is not found in '{rootDir}'"
    )

proc enumerateTokens(
    tokenList : var TokenList, pageNum : Positive, nTokensRead : int
) =

    let startIdx = tokenList.len() - nTokensRead

    for idx in 0..<nTokensRead:
        tokenList[startIdx + idx].id   = idx + 1
        tokenList[startIdx + idx].page = pageNum

proc loadPage*(
    tokenList : var TokenList, rootDir : string, pageNum : int
) : TokenPage =

    result = getPageWithNum(rootDir, pageNum)

    let nTokensRead = loadTokens(tokenList, result.path)

    enumerateTokens(tokenList, result.pageNum, nTokensRead)

proc savePage*(
    tokenList : TokenList, rootDir : string, pageNum : Positive
) =

    if tokenList.len() == 0:
        return

    let saveFileName : string = getTokenPageFileName(
        tokenList[0].date, rootDir, pageNum
    )
    var saveStream : FileStream = openFileStream(saveFileName, fmWrite)

    try:
        for token in tokenList:
            token.save(saveStream)

    finally:
        close(saveStream)

