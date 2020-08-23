import list_spec
import ../value_spec/value_spec
import ../funcs

import terminal
import strutils

proc getMinColWidth(cells : ListCells, colIdx : int) : int =
    result = 0

    for cell in cells:
        result = max(result, cell[colIdx].len())

proc getColumnSizes*(
    cells : ListCells, listSpec : ListSpec, screenCols : int
) : seq[int] =
    newSeq(result, listSpec.len())

    var remainingCols  = screenCols
    var lastStretchIdx = -1

    for idx,colSpec in pairs(listSpec):
        if colSpec.sizePolicy == SizePolicy.Stretch:
            lastStretchIdx = idx

    for idx,colSpec in listSpec.pairs:
        if idx == lastStretchIdx:
            continue

        result[idx]    = colSpec.marginSize + getMinColWidth(cells, idx)
        remainingCols -= result[idx]

    if lastStretchIdx >= 0:
        result[lastStretchIdx] = max(
            listSpec[lastStretchIdx].marginSize, remainingCols
        )
        remainingCols -= result[lastStretchIdx]

    if remainingCols < 0:
        raise newException(OverflowError, "Screen width is too small")

proc printHeader*(
    cells    : ListCells,
    listSpec : ListSpec,
    colSizes : openArray[int],
    useColor : bool
) : string =

    for idx,colSpec in listSpec.pairs:

        if useColor:
            result &= ansiStyleCode(styleUnderscore)

        result &= alignLeft(cells[0][idx], colSizes[idx] - colSpec.marginSize)

        if useColor:
            result &= ansiResetCode

        result &= repeat(' ', colSpec.marginSize)

proc printListBody*(
    cells          : ListCells,
    listSpec       : ListSpec,
    colSizes       : openArray[int],
    rowsColorStyle : openArray[string],
    body           : var seq[string],
) =

    for rowIdx in 1..<len(cells):
        var row : string

        if len(rowsColorStyle[rowIdx]) > 0:
            row &= rowsColorStyle[rowIdx]

        for colIdx,colSpec in pairs(listSpec):
            row &= alignAndFit(
                cells[rowIdx][colIdx],
                colSizes[colIdx] - colSpec.marginSize,
                colSpec.align
            )

            row &= repeat(' ', colSpec.marginSize)

        if len(rowsColorStyle[rowIdx]) > 0:
            row &= ansiResetCode

        body.add(row)

