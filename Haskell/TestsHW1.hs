module TestsHW1 where

import Test.HUnit
import HW1
import QSTKUtil.QSTsUtil
import QSTKUtil.Date
import QSTKUtil.QSTsUtil

t1 = TestCase ( assertEqual "for normalize [[1.0, 2.0], [2.0, 3.0]]"
                [[1.0, 2.0], [1.0, 1.5]]
                (normalize [[1.0, 2.0], [2.0, 3.0]]))

t2 = TestCase ( assertEqual "for volatility [0.0, 0.1, 0.2]"
                0.1
                (volatility [0.0, 0.1, 0.2]))

t3 = TestCase ( assertEqual "for adj_prices [[1.0, 1.5], [1.0, 2.0]]"
                [[0.5, 1.0], [0.75, 1.5]]
                (adj_prices [0.5, 0.5] [[1.0, 2.0], [1.5, 3.0]]))

t4 = TestCase ( assertEqual "for getSharpeRatio [0.1, 0.2, 0.3]"
                31.749015732775096
                (getSharpeRatio [0.1, 0.2, 0.3]))

t5 = TestCase ( assertEqual "for daily [1.0, 1.1]"
                [0.10000000000000009]
                (daily [1.0, 1.1]))

t6 = TestCase ( assertEqual "for daily_rets [[1.0, 1.1]] [0.5, 0.5]"
                [0.0, 1.0]
                (daily_rets [[1.0, 1.0], [2.0, 2.0]] [0.5, 0.5]))


--t5 = TestCase ( assertEqual "for parseNYSE 01/01/2011"
--                01/01/2011
--                (parseNYSE "01/01/2011"))

tests = TestList [  TestLabel "normalize" t1,
                    TestLabel "volatility" t2,
                    TestLabel "adj_prices" t3,
                    TestLabel "getSharpeRatio" t4,
                    TestLabel "daily" t5,
                    TestLabel "daily_rets" t6]
