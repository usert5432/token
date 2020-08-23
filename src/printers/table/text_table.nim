import ../value_spec/value_spec
import ../funcs
import ../../token/token_obj
import ../../token/token_list
import ../../config/color_map
import ../../colors/ansi_color_style

import table_funcs
import table_spec

type
    TextCellSpec = seq[(string,ValueSpec)]

let
    textTableSpec* = initTableSpec(
        cellWidth = 18, cellHeight = 5, marginX = 1, marginY = 0,
    )

    cellSpec : TextCellSpec = @[
        ("I: " , VALUE_SPEC_ID),
        ("D: " , VALUE_SPEC_INFO_DATE),
        ("T: " , VALUE_SPEC_INFO_TIME),
        ("R: " , VALUE_SPEC_REWARD),
        (""    , VALUE_SPEC_DESCR),
    ]

proc getRegularTokenCell*(
    token : Token, tableSpec : TableSpec, cellSpec : TextCellSpec
) : seq[string] =

    for cellRowSpec in cellSpec:
        result.add(
            alignAndFit(
                cellRowSpec[0] & cellRowSpec[1].getValue(token),
                tableSpec.cellWidth, TextAlign.Left
            )
        )

proc getTokenCell*(
    tableSpec : TableSpec,
    tokenList : TokenList,
    tokenIdx  : int,
    pageSize  : int,
    cellSpec  : TextCellSpec
) : seq[string] =

    if tokenIdx >= tokenList.len():
        if tokenIdx >= pageSize:
            return getFilledCell(tableSpec, tableSpec.fillChar)
        else:
            return getFilledCell(tableSpec, ' ')

    return getRegularTokenCell(tokenList[tokenIdx], tableSpec, cellSpec)

proc getTokenCellColorStyle*(
    tokenList : TokenList, tokenIdx : int, cmap : ColorMap, useColor : bool
) : string =

    if tokenIdx >= tokenList.len():
        return ""

    if useColor and cmap.hasKey(tokenList[tokenIdx].reward):
        return cmap[tokenList[tokenIdx].reward].toString()
    else:
        return ""

proc printTextTable*(
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

            tableRow.add(getTokenCell(
                tableSpec, tokenList, tokenIdx, pageSize, cellSpec
            ))
            colorStyleRow.add(
                getCellColorStyle(tokenList, tokenIdx, cmap, useColor)
            )

        cells.add(tableRow)
        cellColorStyles.add(colorStyleRow)

    return printTable(tableSpec, cells, cellColorStyles)

