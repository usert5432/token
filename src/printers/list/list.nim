import list_spec
import list_funcs

import ../../token/token_obj
import ../../token/token_list
import ../../config/color_map
import ../../colors/ansi_color_style
import ../funcs
import ../value_spec/value_spec

import system

proc getListHeader(listSpec : ListSpec, cells : var ListCells) =
    var header : seq[string] = @[]

    for colSpec in listSpec:
        header.add(colSpec.name)

    cells.add(header)

proc getListContents(
    tokenList : TokenList, listSpec : ListSpec, cells : var ListCells
) =

    for token in tokenList:
        var row : seq[string] = @[]

        for colSpec in listSpec:
            row.add(colSpec.getValue(token))

        cells.add(row)

proc getListCells(tokenList : TokenList, listSpec : ListSpec) : ListCells =
    getListHeader(listSpec, result)
    getListContents(tokenList, listSpec, result)

proc getRowColorStyle(
    token : Token, cmap : ColorMap, defBg : AnsiColorStyle, useColor : bool
) : string =

    if not useColor:
        return ""

    var bgColor : string = ""

    if cmap.hasKey(token.reward):
        result  = cmap[token.reward].toString()
        bgColor = cmap[token.reward].bgColor

    if bgColor.len() == 0:
        result &= defBg.toString()

proc getRowsColorStyle(
    tokenList : TokenList, listSpec : ListSpec, cmap : ColorMap,
    useColor : bool
) : seq[string] =

    let altColors : array[2, AnsiColorStyle] = getAltColors(cmap, useColor)

    # Header w/o style
    result.add("")

    for idx,token in tokenList.pairs:
        result.add(getRowColorStyle(
            token, cmap, altColors[idx mod 2], useColor
        ))

proc printList*(
    tokenList  : TokenList,
    listSpec   : ListSpec,
    screenCols : int,
    cmap       : ColorMap,
    useColor   : bool = true
) : seq[string] =

    let cells          = getListCells(tokenList, listSpec)
    let rowsColorStyle = getRowsColorStyle(tokenList, listSpec, cmap, useColor)
    let colSizes       = getColumnSizes(cells, listSpec, screenCols)

    result.add(printHeader(cells, listSpec, colSizes, useColor))
    printListBody(
        cells, listSpec, colSizes, rowsColorStyle, result
    )


