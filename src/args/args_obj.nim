import times

from ../token/token_list import TokenFilter

type
    ArgsKind* {.pure.} = enum
        Add, Del, Export, Graph, Info, List, Table

    ArgsObj* = object of RootObj
        page*    : int          ##[
            Token page number (numeration starts from 1).
            If zero then meaning is interpreted according to the action.
            If negative then it is a page number from the end with
            -1 being the last page
        ]##

        useColor* : bool         ## Colorize output

        case kind* : ArgsKind
        of Add:
            descr*  : string     ## Token description
            reward* : int        ## Token reward value
            date*   : DateTime   ## Date of reward
            meta*   : string     ## Optional metainformation

        of Del, Info:
            id*  : int           ## Token id

        of Export:
            format* : string     ## Format to export tokens to

        of Graph:
            filter* : TokenFilter ## Token Filter
            mode*   : string      ## Binning type { day, week, month, year }
            value*  : bool        ## Make histogram of token value

        of Table:
            subpage* : int       ## Part of a token page that fits the screen
            icons*   : bool      ## Print iconic representation of tokens

        of List:
            listFilter* : TokenFilter ## Token Filter
            offset*     : int         ## Skip first ``offset`` tokens
            limit*      : int         ## List only ``limit`` number of tokens

    Args* = ref ArgsObj

