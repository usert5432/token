import strutils
import terminal

import ../../token/token_list
import ../../config/color_map
import ../../colors/ansi_color_style

import table_spec

proc inferTableShape*(
    tableSpec : var TableSpec, screenX : int, screenY : int
) =
    tableSpec.nCols = int(
        (screenX - TABLE_BORDER_SIZE) /
        (tableSpec.cellWidth + 2 * tableSpec.marginX + TABLE_BORDER_SIZE)
    )

    tableSpec.nRows = int(
        (screenY - TABLE_BORDER_SIZE) /
        (tableSpec.cellHeight + 2 * tableSpec.marginY + TABLE_BORDER_SIZE)
    )

proc getFilledCell*(tableSpec : TableSpec, fillChar : char = ' ') :
    seq[string] =

    let filler = repeat(fillChar, tableSpec.cellWidth)

    for i in 0..<tableSpec.cellHeight:
        result.add(filler)

proc getCellColorStyle*(
    tokenList : TokenList, tokenIdx : int, cmap : ColorMap, useColor : bool
) : string =

    if tokenIdx >= tokenList.len():
        return ""

    if useColor and cmap.hasKey(tokenList[tokenIdx].reward):
        return cmap[tokenList[tokenIdx].reward].toString()
    else:
        return ""

proc printTableHLine(tableSpec : TableSpec) : string =

    let cellSeparator = repeat(
        tableSpec.borderH, tableSpec.cellWidth + 2 * tableSpec.marginX
    )

    return (
        tableSpec.borderC &
        repeat(cellSeparator & tableSpec.borderC, tableSpec.nCols)
    )

proc printTableRow*(
    tableSpec      : TableSpec,
    tableRow       : seq[TableCell],
    rowColorStyles : seq[string],
) : seq[string] =

    if tableRow.len() == 0:
        return

    let xmargin = repeat(' ', tableSpec.marginX)

    for cellRowIdx in 0..<tableRow[0].len():
        var screenRow : string = $tableSpec.borderV

        for tableColIdx in 0..<tableSpec.nCols:
            screenRow &= xmargin

            if rowColorStyles[tableColIdx].len() > 0:
                screenRow &= rowColorStyles[tableColIdx]

            screenRow &= tableRow[tableColIdx][cellRowIdx]

            if rowColorStyles[tableColIdx].len() > 0:
                screenRow &= ansiResetCode

            screenRow &= (xmargin & tableSpec.borderV)

        result.add(screenRow)

proc printTable*(
    tableSpec       : TableSpec,
    cells           : TableCells,
    cellColorStyles : seq[seq[string]],
) : seq[string] =

    if cells.len() == 0:
        return

    result.add(printTableHLine(tableSpec))

    for idx,tableRow in pairs(cells):
        result.add(printTableRow(tableSpec, tableRow, cellColorStyles[idx]))
        result.add(printTableHLine(tableSpec))

