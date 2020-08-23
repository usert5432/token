import token_obj
import token_list
import token_page

import streams

proc saveAll*(tokenList : TokenList, rootDir : string, pageSize : Positive) =

    if len(tokenList) == 0:
        return

    var pageNum       : Positive = 1
    var nTokensOnPage : int      = 0

    var fname      = getTokenPageFileName(tokenList[0].date, rootDir, pageNum)
    var saveStream = openFileStream(fname, fmWrite)

    try:
        for token in tokenList:
            if nTokensOnPage < pageSize:
                nTokensOnPage += 1
            else:
                pageNum      += 1
                nTokensOnPage = 0

                close(saveStream)
                fname      = getTokenPageFileName(token.date, rootDir, pageNum)
                saveStream = openFileStream(fname, fmWrite)

            token.save(saveStream)
    finally:
        close(saveStream)

proc loadAll*(tokenList : var TokenList, rootDir : string) =

    let pages : seq[TokenPage] = listTokenPages(rootDir)

    for page in pages:
        discard loadPage(tokenList, rootDir, page.pageNum)

