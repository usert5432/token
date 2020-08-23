import unittest

import token/token_obj
import token/token_list
import printers/graph/hist_obj

suite "Test Histogram Constructor":

    let testTokenList : TokenList = @[
        # Year 2001 stars with Monday
        initToken(initDateTime(1,  mJan, 2001, 0,  0, 0), 1, "token 1"),
        initToken(initDateTime(1,  mJan, 2001, 5,  0, 0), 2, "token 2"),
        initToken(initDateTime(2,  mJan, 2001, 0,  0, 0), 3, "token 3"),
        initToken(initDateTime(3,  mJan, 2001, 0,  0, 0), 4, "token 4"),
        initToken(initDateTime(3,  mJan, 2001, 0,  0, 0), 4, "token 5"),
        initToken(initDateTime(11, mJan, 2001, 0,  0, 0), 6, "token 6"),
        initToken(initDateTime(11, mJan, 2001, 13, 0, 0), 7, "token 7"),
        initToken(initDateTime(1,  mFeb, 2001, 00, 0, 0), 8, "token 8"),
    ]

    proc toRA(a : openarray[int]) : array[1..10, uint] =
        assert(len(a) == len(result))

        for i,x in pairs(a):
            result[i + low(result)] = uint(x)

    template compareHists(null : Hist, test : Hist) =
        check(null.mode      == test.mode)
        check(null.firstDate == test.firstDate)
        check(null.lastDate  == test.lastDate)
        check(null.valueHist == test.valueHist)
        check(len(null.bins) == len(test.bins))

        for idx in low(null.bins)..high(null.bins):
            checkpoint("Bin: " & $idx)
            check(null.bins[idx].date    == test.bins[idx].date)
            check(null.bins[idx].rewards == test.bins[idx].rewards)
            check(null.bins[idx].height  == test.bins[idx].height)

    test "Test Day Hist Constructor":
        let nullHist = Hist(
            mode      : GraphMode.Day,
            firstDate : initDateTime(1, mJan, 2001, 00, 0, 0),
            lastDate  : initDateTime(4, mJan, 2001, 00, 0, 0),
            valueHist : false,
            bins      : @[
                HistBin(
                    rewards : toRA([1, 1, 0, 0, 0, 0, 0, 0, 0, 0]),
                    date    : initDateTime(1, mJan, 2001, 00, 0, 0),
                    height  : 2
                ),
                HistBin(
                    rewards : toRA([0, 0, 1, 0, 0, 0, 0, 0, 0, 0]),
                    date    : initDateTime(2, mJan, 2001, 00, 0, 0),
                    height  : 1
                ),
                HistBin(
                    rewards : toRA([0, 0, 0, 2, 0, 0, 0, 0, 0, 0]),
                    date    : initDateTime(3, mJan, 2001, 00, 0, 0),
                    height  : 2
                ),
            ]
        )

        let testHist = constructHist(testTokenList[0..4], GraphMode.Day, false)

        compareHists(nullHist, testHist)

    test "Test Day Value Hist Constructor":
        let nullHist = Hist(
            mode      : GraphMode.Day,
            firstDate : initDateTime(1, mJan, 2001, 00, 0, 0),
            lastDate  : initDateTime(4, mJan, 2001, 00, 0, 0),
            valueHist : true,
            bins      : @[
                HistBin(
                    rewards : toRA([1, 1, 0, 0, 0, 0, 0, 0, 0, 0]),
                    date    : initDateTime(1, mJan, 2001, 00, 0, 0),
                    height  : 3
                ),
                HistBin(
                    rewards : toRA([0, 0, 1, 0, 0, 0, 0, 0, 0, 0]),
                    date    : initDateTime(2, mJan, 2001, 00, 0, 0),
                    height  : 3
                ),
                HistBin(
                    rewards : toRA([0, 0, 0, 2, 0, 0, 0, 0, 0, 0]),
                    date    : initDateTime(3, mJan, 2001, 00, 0, 0),
                    height  : 8
                ),
            ]
        )

        let testHist = constructHist(testTokenList[0..4], GraphMode.Day, true)

        compareHists(nullHist, testHist)

    test "Test Week Hist Constructor":
        let nullHist = Hist(
            mode      : GraphMode.Week,
            firstDate : initDateTime(1, mJan, 2001, 00, 0, 0),
            lastDate  : initDateTime(5, mFeb, 2001, 00, 0, 0),
            valueHist : false,
            bins      : @[
                HistBin(
                    rewards : toRA([1, 1, 1, 2, 0, 0, 0, 0, 0, 0]),
                    date    : initDateTime(1, mJan, 2001, 00, 0, 0),
                    height  : 5
                ),
                HistBin(
                    rewards : toRA([0, 0, 0, 0, 0, 1, 1, 0, 0, 0]),
                    date    : initDateTime(8, mJan, 2001, 00, 0, 0),
                    height  : 2
                ),
                HistBin(
                    rewards : toRA([0, 0, 0, 0, 0, 0, 0, 0, 0, 0]),
                    date    : initDateTime(15, mJan, 2001, 00, 0, 0),
                    height  : 0
                ),
                HistBin(
                    rewards : toRA([0, 0, 0, 0, 0, 0, 0, 0, 0, 0]),
                    date    : initDateTime(22, mJan, 2001, 00, 0, 0),
                    height  : 0
                ),
                HistBin(
                    rewards : toRA([0, 0, 0, 0, 0, 0, 0, 1, 0, 0]),
                    date    : initDateTime(29, mJan, 2001, 00, 0, 0),
                    height  : 1
                ),
            ]
        )

        let testHist = constructHist(testTokenList, GraphMode.Week, false)

        compareHists(nullHist, testHist)

    test "Test Month Hist Constructor":
        let nullHist = Hist(
            mode      : GraphMode.Month,
            firstDate : initDateTime(1, mJan, 2001, 00, 0, 0),
            lastDate  : initDateTime(1, mMar, 2001, 00, 0, 0),
            valueHist : false,
            bins      : @[
                HistBin(
                    rewards : toRA([1, 1, 1, 2, 0, 1, 1, 0, 0, 0]),
                    date    : initDateTime(1, mJan, 2001, 00, 0, 0),
                    height  : 7
                ),
                HistBin(
                    rewards : toRA([0, 0, 0, 0, 0, 0, 0, 1, 0, 0]),
                    date    : initDateTime(1, mFeb, 2001, 00, 0, 0),
                    height  : 1
                ),
            ]
        )

        let testHist = constructHist(testTokenList, GraphMode.Month, false)

        compareHists(nullHist, testHist)

    test "Test Year Hist Constructor":
        let nullHist = Hist(
            mode      : GraphMode.Year,
            firstDate : initDateTime(1, mJan, 2001, 00, 0, 0),
            lastDate  : initDateTime(1, mJan, 2002, 00, 0, 0),
            valueHist : false,
            bins      : @[
                HistBin(
                    rewards : toRA([1, 1, 1, 2, 0, 1, 1, 1, 0, 0]),
                    date    : initDateTime(1, mJan, 2001, 00, 0, 0),
                    height  : 8
                ),
            ]
        )

        let testHist = constructHist(testTokenList, GraphMode.Year, false)

        compareHists(nullHist, testHist)

