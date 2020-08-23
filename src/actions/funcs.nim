import strformat
import ../token/token_list

proc getTokenIndex*(tokenID : int, tokenList : TokenList) : int =
    ## Convert token number in human representation ``tokenID``
    ## into an index in range [0, len(``token_list``)) that can be used to
    ## slice array ``tokenList``.
    var index : int

    if tokenID > 0:
        index = tokenID - 1
    elif tokenID == 0:
        index = -1
    else:
        index = tokenList.len() + tokenID

    if (index < 0) or (index >= tokenList.len()):
        raise newException(
            RangeError,
            fmt"Token index {tokenID} is out of range: " &
            fmt"[1, {tokenList.len()}]"
        )

    return index

