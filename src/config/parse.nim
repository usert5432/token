import os
import strformat
import tables
import parsecfg

from strutils import parseInt, startsWith

import ./color_map
import ./config_obj
import ../colors/ansi_color_style
import ../colors/parse

const
    COLOR_PREFIX  = "color."
    REWARD_PREFIX = "reward."
    CONF_TOKENDIR = "tokenDir"
    CONF_PAGESIZE = "pageSize"

proc loadColor(k,v : string) : tuple[name : string, cs : AnsiColorStyle] =
    try:
        let name = k[len(COLOR_PREFIX)..^1]
        return (name, parseAnsiColorStyle(v))
    except:
        let msg = getCurrentExceptionMsg()
        raise newException(
            ValueError, fmt"Failed to parse color line '{k} = {v}': {msg}"
        )

proc parseRewardNum(name : string) : int =
    try:
        let strNum : string = name[len(REWARD_PREFIX)..^1]
        return parseInt(strNum)
    except:
        let msg = getCurrentExceptionMsg()
        raise newException(
            ValueError, fmt"Failed to parse reward number '{name}': {msg}"
        )

proc loadTokenDir(dict : parsecfg.Config) : string =

    result = dict.getSectionValue("", CONF_TOKENDIR)

    if len(result) == 0:
        raise newException(ValueError, fmt"`{CONF_TOKENDIR}` is missing")

    result = expandTilde(result)

proc loadPageSize(dict : parsecfg.Config) : int =

    let strPageSize = dict.getSectionValue("", "pageSize")

    if len(strPageSize) == 0:
        raise newException(ValueError, fmt"`{CONF_PAGESIZE}` is missing")

    try:
        result = parseInt(strPageSize)
    except ValueError:
        raise newException(ValueError, fmt"Failed to parse `{CONF_PAGESIZE}`")

    if result <= 0:
        raise newException(
            ValueError, "`{CONF_PAGESIZE}` must be greater than zero"
        )

proc loadColorMap*(dict : parsecfg.Config, cmap : var ColorMap) =

    if not dict.hasKey(""):
        return

    for k,v in pairs(dict[""]):
        if startsWith(k, COLOR_PREFIX):
            let (name, value) = loadColor(k, v)

            if startsWith(name, REWARD_PREFIX):
                let num = parseRewardNum(name)
                cmap.reward.add(num, value)
            else:
                cmap.misc.add(name, value)

proc load*(cfgFile : string) : config_obj.Config =

    var dict = loadConfig(cfgFile)

    try:
        result.cfgFile  = cfgFile
        result.rootDir  = loadTokenDir(dict)
        result.pageSize = loadPageSize(dict)
        result.cmap     = initColorMap()
    except ValueError as e:
        raise newException(
            ValueError,
            fmt"Failed to parse config file '${cfgFile}': " & e.msg
        )

    loadColorMap(dict, result.cmap)

