import tables
import ../colors/ansi_color_style

type
    ColorMap* = object
        reward* : Table[int,    AnsiColorStyle]
        misc*   : Table[string, AnsiColorStyle]

proc initColorMap*() : ColorMap =
    result.reward = initTable[int,    AnsiColorStyle]()
    result.misc   = initTable[string, AnsiColorStyle]()

proc hasKey*(cmap : ColorMap, key : string) : bool =
    return cmap.misc.hasKey(key)

proc hasKey*(cmap : ColorMap, key : int) : bool =
    return cmap.reward.hasKey(key)

proc `[]`*(cmap : ColorMap, key : string) : AnsiColorStyle =
    return cmap.misc[key]

proc `[]`*(cmap : ColorMap, key : int) : AnsiColorStyle =
    return cmap.reward[key]

proc getOrDefault*(
    cmap : ColorMap, key : int, default : AnsiColorStyle
) : AnsiColorStyle =
    return cmap.reward.getOrDefault(key, default)

proc getOrDefault*(
    cmap : ColorMap, key : string, default : AnsiColorStyle
) : AnsiColorStyle =
    return cmap.misc.getOrDefault(key, default)

