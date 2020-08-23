import unittest
include colors/parse

suite "Test Color Parsers":

    test "Test Style Parsing":
        check(tryParseStyle("")           == "")
        check(tryParseStyle("blink")      == ansiStyleCode(styleBlink))
        check(tryParseStyle("bright")     == ansiStyleCode(styleBright))
        check(tryParseStyle("dim")        == ansiStyleCode(styleDim))
        check(tryParseStyle("hidden")     == ansiStyleCode(styleHidden))
        check(tryParseStyle("italic")     == ansiStyleCode(styleItalic))
        check(tryParseStyle("reverse")    == ansiStyleCode(styleReverse))
        check(tryParseStyle("underscore") == ansiStyleCode(styleUnderscore))
        check(
            tryParseStyle("strikethrough") == ansiStyleCode(styleStrikethrough)
        )

        expect(KeyError): discard tryParseStyle("unknown")
        expect(KeyError): discard tryParseStyle("Blink")
        expect(KeyError): discard tryParseStyle(" blink ")


    test "Test Base Fg Colors Parsing":
        check(tryParseC16ColorFg("") == "")
        check(
            tryParseC16ColorFg("red")     == ansiForegroundColorCode(fgRed)
        )
        check(
            tryParseC16ColorFg("green")   == ansiForegroundColorCode(fgGreen)
        )
        check(
            tryParseC16ColorFg("blue")    == ansiForegroundColorCode(fgBlue)
        )
        check(
            tryParseC16ColorFg("yellow")  == ansiForegroundColorCode(fgYellow)
        )
        check(
            tryParseC16ColorFg("magenta") == ansiForegroundColorCode(fgMagenta)
        )
        check(
            tryParseC16ColorFg("cyan")    == ansiForegroundColorCode(fgCyan)
        )
        check(
            tryParseC16ColorFg("white")   == ansiForegroundColorCode(fgWhite)
        )

        expect(ValueError): discard tryParseC16ColorFg("unknown")
        expect(ValueError): discard tryParseC16ColorFg("Red")
        expect(ValueError): discard tryParseC16ColorFg(" red ")

    test "Test Empty Full Color Style Parsing":
        check(parseAnsiColorStyle("") == AnsiColorStyle())

    test "Test Simple Fg Full Color Style Parsing":
        check(
            parseAnsiColorStyle("red") == AnsiColorStyle(
                fgColor : ansiForegroundColorCode(fgRed)
            )
        )

    test "Test Simple Bg Full Color Style Parsing":
        check(
            parseAnsiColorStyle("on red") == AnsiColorStyle(
                bgColor : ansiBackgroundColorCode(bgRed)
            )
        )

    test "Test Fg Full Color Style Parsing":
        check(
            parseAnsiColorStyle("bright red") == AnsiColorStyle(
                fgColor : ansiForegroundColorCode(fgRed),
                style   : ansiStyleCode(styleBright)
            )
        )

    test "Test Full Color Style Parsing":
        check(
            parseAnsiColorStyle("blink green on blue") == AnsiColorStyle(
                fgColor : ansiForegroundColorCode(fgGreen),
                bgColor : ansiBackgroundColorCode(bgBlue),
                style   : ansiStyleCode(styleBlink)
            )
        )

    test "Test TrueColor Full Color Style Parsing":
        check(
            parseAnsiColorStyle("darkred on darkblue") == AnsiColorStyle(
                fgColor : ansiForegroundColorCode(colDarkRed),
                bgColor : ansiBackgroundColorCode(colDarkBlue),
            )
        )

    test "Test Special Name Full Color Style Parsing":
        # These colors have 'on' combination in their names
        check(
            parseAnsiColorStyle("crimson on salmon") == AnsiColorStyle(
                fgColor : ansiForegroundColorCode(colCrimson),
                bgColor : ansiBackgroundColorCode(colSalmon),
            )
        )


