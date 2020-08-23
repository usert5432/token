import sequtils
import strformat
import strutils
import terminal

import hist_obj
import ../funcs
import ../list/list_spec
import ../list/list_funcs
import ../value_spec/value_spec
import ../../config/color_map
import ../../colors/ansi_color_style

let DUMMY_LIST_SPEC : ListSpec = @[ VALUE_SPEC_DATE, VALUE_SPEC_DESCR ]

proc printBin(
    bin        : HistBin,
    printWidth : int,
    valueHist : bool,
    histHeight : uint,
    cmap       : ColorMap,
    useColor   : bool
) : string =

    var nfill = 0
    # NOTE: -3 because: (left + right vline) + right margin
    let scale = float(printWidth - 3) / float(histHeight)

    result = "|"
    nfill += 1

    for reward in low(bin.rewards)..high(bin.rewards):
        var w = 0

        if valueHist:
            w = int(float(reward) * float(bin.rewards[reward]) * scale)
        else:
            w = int(float(bin.rewards[reward]) * scale)

        if w == 0:
            continue

        if useColor:
            result &= cmap[reward].toString()

        result &= repeat('X', w)
        nfill += w

        if useColor:
            result &= ansiResetCode

    result &= repeat(' ', printWidth - 2 - nfill)
    result &= '|'

proc getGraphBackbone(hist : Hist) : ListCells =
    result.add(@[ "Date", "Values" ])

    for bin in hist.bins:
        result.add(@[ " " & binDateToString(bin.date, hist.mode), "" ])

    result.add(@[ "Scale", "" ])

proc printGraphBody(
    cells          : seq[seq[string]],
    colSizes       : openArray[int],
    body           : var seq[string],
) =

    for rowIdx in 1..<len(cells):
        var row : string

        row &= alignAndFit(cells[rowIdx][0], colSizes[0] - 1, TextAlign.Right)
        row &= " " & cells[rowIdx][1]

        body.add(row)

proc printScale(histHeight : uint, colWidth : int) : string =
    let minStr = "0 "
    let maxStr = " " & $histHeight

    let midVal = float(histHeight) / 2
    let midStr = fmt" {midVal:.1f} "

    let freeSpace = colWidth - len(minStr) - len(maxStr) - len(midStr) - 1

    if freeSpace < 0:
        return ""

    let freeLeft  = int(freeSpace / 2)
    let freeRight = freeSpace - freeLeft

    result = (
        minStr & repeat('-', freeLeft) &
        midStr & repeat('-', freeRight) &
        maxStr
    )

proc printGraph*(
    hist       : Hist,
    mode       : GraphMode,
    screenCols : int,
    cmap       : ColorMap,
    useColor   : bool = true
) : seq[string] =

    if len(hist.bins) == 0:
        return @[]

    let histHeight = max(map(hist.bins, proc (x : HistBin) : uint = x.height))
    var graphCells = getGraphBackbone(hist)
    let colSizes   = getColumnSizes(graphCells, DUMMY_LIST_SPEC, screenCols)

    for idx,bin in pairs(hist.bins):
        graphCells[idx+1][1] = printBin(
            bin, colSizes[1], hist.valueHist, histHeight, cmap, useColor
        )

    graphCells[^1][1] = printScale(histHeight, colSizes[1])

    result.add(printHeader(graphCells, DUMMY_LIST_SPEC, colSizes, useColor))
    printGraphBody(graphCells, colSizes, result)

