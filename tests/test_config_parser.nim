import colors
import terminal
import unittest

include config/parse

proc createSimpleDict(k, v : string) : parsecfg.Config =
    newOrderedTable({ "" : newOrderedTable({ k : v }) })

proc createSimpleDict(pairs : openArray[(string, string)]) : parsecfg.Config =
    newOrderedTable({ "" : newOrderedTable(pairs) })

suite "Test Config Parser":

    test "Test loadColor":
        check(loadColor("color.c1", "red") == (
            "c1", AnsiColorStyle(fgColor : ansiForegroundColorCode(fgRed))
        ))

        check(loadColor("color.c2", "on salmon") == (
            "c2", AnsiColorStyle(bgColor : ansiBackgroundColorCode(colSalmon))
        ))

        expect(ValueError): discard loadColor("short", "red")
        expect(ValueError): discard loadColor("color.c1", "badcolorname")

    test "Test parseRewardNum":
        check(parseRewardNum("reward.0")   == 0)
        check(parseRewardNum("reward.10")  == 10)
        check(parseRewardNum("reward.-10") == -10)

        expect(ValueError): discard parseRewardNum("short")
        expect(ValueError): discard parseRewardNum("malformated.0")
        expect(ValueError): discard parseRewardNum("reward.notnum")

    test "Test loadPageSize":
        check(loadPageSize(createSimpleDict(CONF_PAGESIZE, "10")) == 10)

        expect(ValueError):
            discard loadPageSize(createSimpleDict(CONF_PAGESIZE, "-1"))

        expect(ValueError):
            discard loadPageSize(createSimpleDict(CONF_PAGESIZE, "0"))

        expect(ValueError):
            discard loadPageSize(createSimpleDict(CONF_PAGESIZE, "abcdefghi"))

        expect(ValueError): discard loadPageSize(newConfig())

    test "Test loadTokenDir":
        check(loadTokenDir(createSimpleDict(CONF_TOKENDIR, "10")) == "10")
        check(loadTokenDir(createSimpleDict(CONF_TOKENDIR, "a")) == "a")
        check(
            loadTokenDir(createSimpleDict(CONF_TOKENDIR, "a/b/c")) == "a/b/c"
        )

        expect(ValueError): discard loadTokenDir(newConfig())

    test "Test empty loadColorMap":
        let cmapNull = initColorMap()
        var cmapTest = initColorMap()

        loadColorMap(newConfig(), cmapTest)

        check(cmapNull == cmapTest)

    test "Test misc part of loadColorMap":
        var cmapNull = initColorMap()
        cmapNull.misc.add(
            "test", AnsiColorStyle(fgColor : ansiForegroundColorCode(fgRed))
        )
        let config    = createSimpleDict(COLOR_PREFIX & "test", "red")
        var cmapTest = initColorMap()

        loadColorMap(config, cmapTest)

        check(cmapNull == cmapTest)

    test "Test reward part of loadColorMap":
        var cmapNull = initColorMap()
        cmapNull.reward.add(
            5, AnsiColorStyle(fgColor : ansiForegroundColorCode(fgRed))
        )
        let config    = createSimpleDict(
            COLOR_PREFIX & REWARD_PREFIX & "5", "red"
        )
        var cmapTest = initColorMap()

        loadColorMap(config, cmapTest)

        check(cmapNull == cmapTest)

    test "Test complex loadColorMap":
        var cmapNull = initColorMap()
        cmapNull.reward.add(
            2, AnsiColorStyle(
                fgColor : ansiForegroundColorCode(colCrimson),
                bgColor : ansiBackgroundColorCode(colSalmon),
                style   : ansiStyleCode(styleBlink)
            )
        )
        cmapNull.reward.add(
            5, AnsiColorStyle(fgColor : ansiForegroundColorCode(fgGreen))
        )
        cmapNull.misc.add(
            "test1", AnsiColorStyle(fgColor : ansiForegroundColorCode(fgBlue))
        )
        cmapNull.misc.add(
            "test2", AnsiColorStyle(
                fgColor : ansiForegroundColorCode(fgGreen),
                bgColor : ansiBackgroundColorCode(colPurple),
                style   : ansiStyleCode(styleBright)
            )
        )

        let config    = createSimpleDict({
            COLOR_PREFIX & REWARD_PREFIX & "2" : "blink crimson on salmon",
            COLOR_PREFIX & REWARD_PREFIX & "5" : "green",
            COLOR_PREFIX & "test1"             : "blue",
            COLOR_PREFIX & "test2"             : "bright green on purple",
        });
        var cmapTest = initColorMap()

        loadColorMap(config, cmapTest)

        check(cmapNull == cmapTest)

