import sequtils

import ../../token/token_obj
import ../../config/color_map
import ../../colors/ansi_color_style
import ../value_spec/value_spec
import ../list/list_spec
import ../list/list_funcs
import ../funcs

type InfoSpec* = seq[ValueSpec]

let INFO_COLS_SPEC = @[
    ValueSpec(
        align      : TextAlign.Right,
        getValue   : proc (token : Token) : string = "",
        name       : "Name",
        marginSize : 1,
        sizePolicy : SizePolicy.Fixed,
    ),
    ValueSpec(
        align      : TextAlign.Floating,
        getValue   : proc (token : Token) : string = "",
        name       : "Value",
        marginSize : 0,
        sizePolicy : SizePolicy.Stretch,
    ),
]

proc printInfo*(
    token      : Token,
    infoSpec   : InfoSpec,
    screenCols : int,
    cmap       : ColorMap,
    useColor   : bool = true
) : seq[string] =

    var cells          : ListCells
    var rowsColorStyle : seq[string]

    let altColors = getAltColors(cmap, useColor)

    cells.add(INFO_COLS_SPEC.map(proc (x : ValueSpec) : string = x.name))
    rowsColorStyle.add("")

    for rowIdx,rowSpec in pairs(infoSpec):
        cells.add(@[rowSpec.name, rowSpec.getValue(token)])

        if useColor:
            rowsColorStyle.add(altColors[(rowIdx and 1)].toString())
        else:
            rowsColorStyle.add("")

    let colSizes = getColumnSizes(cells, INFO_COLS_SPEC, screenCols)

    result = @[ printHeader(cells, INFO_COLS_SPEC, colSizes, useColor) ]
    printListBody(
        cells, INFO_COLS_SPEC, colSizes, rowsColorStyle, result
    )

