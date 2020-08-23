import colors
import strutils
import tables
import terminal

import ansi_color_style

const
    NAME_STYLE_MAP = {
        "bright"        : styleBright,
        "dim"           : styleDim,
        "italic"        : styleItalic,
        "underscore"    : styleUnderscore,
        "blink"         : styleBlink,
        "reverse"       : styleReverse,
        "hidden"        : styleHidden,
        "strikethrough" : styleStrikethrough,
    }.toTable

    NAME_FGCOLOR_MAP = {
        "red"     : fgRed,
        "green"   : fgGreen,
        "blue"    : fgBlue,
        "yellow"  : fgYellow,
        "magenta" : fgMagenta,
        "cyan"    : fgCyan,
        "white"   : fgWhite,
        "black"   : fgBlack,
    }.toTable

    NAME_BGCOLOR_MAP = {
        "red"     : bgRed,
        "green"   : bgGreen,
        "blue"    : bgBlue,
        "yellow"  : bgYellow,
        "magenta" : bgMagenta,
        "cyan"    : bgCyan,
        "white"   : bgWhite,
        "black"   : bgBlack,
    }.toTable


proc tryParseStyle(spec : string) : string =

    if spec.len() == 0:
        return ""

    ansiStyleCode(NAME_STYLE_MAP[spec])

proc tryParseC16ColorFg(spec : string) : string =

    if spec.len() == 0:
        return ""

    ansiForegroundColorCode(NAME_FGCOLOR_MAP[spec])

proc ansiBackgroundColorCode(bgColor : BackgroundColor) : string =
    return ansiForegroundColorCode(
        cast[ForegroundColor](bgColor), bright = false
    )

proc tryParseC16ColorBg(spec : string) : string =

    if spec.len() == 0:
        return ""

    ansiBackgroundColorCode(NAME_BGCOLOR_MAP[spec])

proc splitSpecIntoFgBgParts(spec : string) : tuple[fg : string, bg : string] =

    if spec.startsWith("on "):
        return ("", strip(spec[2..^1]))

    let pairFgBg = split(spec, " on ")

    var fgColorStyleSpec : string
    var bgColorSpec      : string

    case len(pairFgBg)
    of 0:
        discard
    of 1:
        fgColorStyleSpec = strip(pairFgBg[0])
    of 2:
        fgColorStyleSpec = strip(pairFgBg[0])
        bgColorSpec      = strip(pairFgBg[1])
    else:
        raise newException(
            ValueError, "Failed to parse color spec: '$1'" % [ spec ]
        )

    (fgColorStyleSpec, bgColorSpec)

proc parseFgColorStyleSpec(spec : string) :
    tuple[color : string, style : seq[string]] =

    var styleSpecList = splitWhitespace(spec)
    var color : string

    if styleSpecList.len() > 0:
        color = pop(styleSpecList)

    (color, styleSpecList)

proc parseAnsiColorStyle*(spec : string) : AnsiColorStyle =

    let (fgColorStyleSpec, bgColorSpec) = splitSpecIntoFgBgParts(spec)
    let (fgColorSpec, styleSpecList) = parseFgColorStyleSpec(fgColorStyleSpec)

    var style   : string
    var fgColor : string
    var bgColor : string

    try:
        fgColor = tryParseC16ColorFg(fgColorSpec)
    except KeyError:
        fgColor = ansiForegroundColorCode(parseColor(fgColorSpec))

    try:
        bgColor = tryParseC16ColorBg(bgColorSpec)
    except KeyError:
        bgColor = ansiBackgroundColorCode(parseColor(bgColorSpec))

    for styleSpec in styleSpecList:
        style &= tryParseStyle(styleSpec)

    return AnsiColorStyle(bgColor : bgColor, fgColor : fgColor, style : style)

