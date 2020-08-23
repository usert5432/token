import sequtils
import strutils

import ../../token/token_obj
import ../../token/token_list
import ../../config/color_map

import table_spec
import table_funcs

let
    iconTableSpec* = initTableSpec(
        cellWidth = 5, cellHeight = 3, marginX = 1, marginY = 0
    )

proc getIconTokenCell*(token : Token, tableSpec : TableSpec) : seq[string] =
    ## Make ASCII "art" cell representing reward value

    let r        = token.reward
    let fillChar = '0'

    result = sequtils.repeat(
        strutils.repeat(' ', tableSpec.cellWidth), tableSpec.cellHeight
    )

    if r >= 1:
        result[0][2] = fillChar
    if r >= 2:
        result[1][4] = fillChar
    if r >= 3:
        result[2][2] = fillChar
    if r >= 4:
        result[1][0] = fillChar
    if r >= 5:
        result[0][0] = fillChar
    if r >= 6:
        result[0][4] = fillChar
    if r >= 7:
        result[2][4] = fillChar
    if r >= 8:
        result[2][0] = fillChar
    if r >= 9:
        result[1][2] = fillChar

proc getTokenCell*(
    tableSpec : TableSpec,
    tokenList : TokenList,
    tokenIdx  : int,
    pageSize  : int,
) : seq[string] =

    if tokenIdx >= tokenList.len():
        if tokenIdx >= pageSize:
            return getFilledCell(tableSpec, tableSpec.fillChar)
        else:
            return getFilledCell(tableSpec, ' ')

    return getIconTokenCell(tokenList[tokenIdx], tableSpec)

proc printIconTable*(
    tableSpec : TableSpec,
    tokenList : TokenList,
    offset    : int,
    pageSize  : int,
    cmap      : ColorMap,
    useColor  : bool = true
) : seq[string] =

    var cells           : TableCells
    var cellColorStyles : seq[seq[string]]

    for tableRowIdx in 0..<tableSpec.nRows:
        var tableRow      : seq[TableCell]
        var colorStyleRow : seq[string]

        for tableColIdx in 0..<tableSpec.nCols:
            let tokenIdx = offset + tableRowIdx * tableSpec.nCols + tableColIdx

            tableRow.add(
                getTokenCell(tableSpec, tokenList, tokenIdx, pageSize)
            )
            colorStyleRow.add(
                getCellColorStyle(tokenList, tokenIdx, cmap, useColor)
            )

        cells.add(tableRow)
        cellColorStyles.add(colorStyleRow)

    return printTable(tableSpec, cells, cellColorStyles)

