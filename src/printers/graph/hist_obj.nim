import times

import ../../token/token_obj
import ../../token/token_list

type
    GraphMode* {.pure.} = enum Day, Week, Month, Year

    HistBin* = object
        rewards*    : array[1..10, uint]
        date*       : DateTime
        height*     : uint

    Hist* = object
        mode*      : GraphMode
        bins*      : seq[HistBin]
        firstDate* : DateTime
        lastDate*  : DateTime
        valueHist* : bool

const
    DATE_FORMATS : array[GraphMode, string] = [
        "yyyy-MM-dd",
        "yyyy-MM-dd",
        "yyyy-MM",
        "yyyy",
    ]

proc binDateToString*(date : DateTime, mode : GraphMode) : string =
    format(date, DATE_FORMATS[mode])

proc getStartBinDate(token : Token, mode : GraphMode) : DateTime =
    let date = local(token.date)

    case mode
    of GraphMode.Day:
        return initDateTime(
            date.monthday, date.month, date.year, 0, 0, 0, 0, date.timezone
        )

    of GraphMode.Week:
        let yearStart = initDateTime(
            1, mJan, date.year, 0, 0, 0, 0, date.timezone
        )
        let weeksSinceYearStart = (date - yearStart).inWeeks()

        return yearStart + initDuration(weeks = weeksSinceYearStart)

    of GraphMode.Month:
        return initDateTime(
            1, date.month, date.year, 0, 0, 0, 0, date.timezone
        )

    of GraphMode.Year:
        return initDateTime(1, mJan, date.year, 0, 0, 0, 0, date.timezone)

proc getNextBinDate(prevDate : DateTime, mode : GraphMode) : DateTime =

    case mode
    of GraphMode.Day:
        return prevDate + days(1)

    of GraphMode.Week:
        return prevDate + weeks(1)

    of GraphMode.Month:
        return prevDate + months(1)

    of GraphMode.Year:
        return prevDate + years(1)

proc calcBinHeights(hist : var Hist) =

    for bin in mitems(hist.bins):
        for reward in low(bin.rewards)..high(bin.rewards):
            if hist.valueHist:
                bin.height += (uint(reward) * bin.rewards[reward])
            else:
                bin.height += bin.rewards[reward]

proc constructHist*(
    tokenList : TokenList, mode : GraphMode, valueHist : bool
) : Hist =

    result.mode      = mode
    result.valueHist = valueHist

    if len(tokenList) == 0:
        return result

    var currDate = getStartBinDate(tokenList[0], mode)
    var nextDate = getNextBinDate(currDate, mode)

    result.firstDate = currDate

    var histBin = HistBin(date : currDate)

    for token in tokenList:
        while local(token.date) >= nextDate:
            result.bins.add(histBin)
            let tmp  = nextDate
            nextDate = getNextBinDate(nextDate, mode)
            currDate = tmp
            histBin  = HistBin(date : currDate)

        histBin.rewards[token.reward] += 1

    result.bins.add(histBin)
    result.lastDate = nextDate

    calcBinHeights(result)

