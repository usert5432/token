import math
import strutils

import ../colors/ansi_color_style
import ../config/color_map
import value_spec/value_spec

proc alignAndFit*(str : string, size : int, align : TextAlign) : string =

    if size <= 0:
        return ""

    let origLen = len(str)

    if origLen >= size:
        if align == TextAlign.Floating:
            return str
        else:
            return str[0..<size]

    let nMissing : int = size - origLen
    var nLeft, nRight : int

    case align
    of TextAlign.Left, TextAlign.Floating:
        nLeft  = 0
        nRight = nMissing - nLeft

    of TextAlign.Right:
        nRight = 0
        nLeft  = nMissing - nRight

    of TextAlign.Center:
        nLeft  = toInt(floor(nMissing / 2))
        nRight = nMissing - nLeft

    result = repeat(' ', nLeft) & str & repeat(' ', nRight)

proc getAltColors*(cmap : ColorMap, useColor : bool) :
    array[2, AnsiColorStyle] =

    if useColor:
        return [
            cmap.getOrDefault("alt0", AnsiColorStyle()),
            cmap.getOrDefault("alt1", AnsiColorStyle())
        ]
    else:
        return [ AnsiColorStyle(), AnsiColorStyle() ]


