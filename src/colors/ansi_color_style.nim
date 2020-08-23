type
    AnsiColorStyle* = object
        bgColor* : string
        fgColor* : string
        style*   : string

proc toString*(cs : AnsiColorStyle) : string =
    return cs.style & cs.fgColor & cs.bgColor

