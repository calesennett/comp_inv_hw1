module HW1
    (   normalize,
        volatility,
        adj_prices,
        daily_rets
    ) where

import qualified QSTKUtil.QSTsUtil as TSU
import qualified QSTKUtil.QSDateUtil as DU
import qualified QSTKUtil.Math.Statistics as Stats
import QSTKUtil.Date
import qualified Lib.DataParser as DP
import Data.List
import Control.Monad.IO.Class
import Data.Ord

main =  do
        p <- mapM (DP.readFrom (parseNYSE "01/01/2011") (parseNYSE "01/31/2011")) ["AAPL", "GLD", "GOOG", "XOM"]
        let prices = reverse $ transpose (map read p)
        let distro = optimal_alloc prices
        let rets = daily_rets prices distro
        print $ "Optimal Allocation: " ++ show (distro)
        print $ "Volatility: " ++ show (volatility $ rets)
        print $ "Sharpe Ratio: " ++ show (TSU.getSharpeRatio $ rets)
        print $ "Average Daily Return: " ++ show (Stats.average $ rets)
        print $ "Cumulative Return: " ++ show ((sum $ rets) + 1)

-- normalize all stock prices
-- params :: all stock prices
normalize :: [[Double]] -> [[Double]]
normalize ([]:_) = []
normalize all@((a):(b):c) = [map (/ first) firstAll] ++ normalize tails'
              where first     = head a
                    firstAll  = map head all
                    tails'    = map tail all

-- compute volatility of list of returns
volatility :: [Double] -> Double
volatility xs = Stats.stddev xs

-- multiply prices by given distribution
-- params :: allocation -> prices for all stocks
adj_prices :: [Double] -> [[Double]] -> [[Double]]
adj_prices [] [] = []
adj_prices d ps = [map (* (head d)) (head ps)] ++ (adj_prices (tail d) (tail ps))

-- generate daily returns for a portfolio
-- params :: allocation
daily_rets ::[[Double]] -> [Double] -> [Double]
daily_rets ps d = 0.0 : (TSU.daily $ map sum $ transpose $ adj_prices d $ normalize ps)

-- generates daily_returns for all legal allocations
all_daily ps = map (daily_rets ps) legal_allocs

-- tuples of (allocation, sharpe) for all legal allocations
all_sharpes ps = zip legal_allocs $ map TSU.getSharpeRatio $ all_daily ps

-- get allocation with highest Sharpe Ratio
optimal_alloc :: [[Double]] -> [Double]
optimal_alloc ps = fst $ maximumBy (comparing snd) $ all_sharpes ps

-- generate legal portfolio allocations
allocs = [0.0, 0.1 .. 1.0]
legal_allocs = [[a,b,c,d] |  a <- allocs,
                             b <- allocs,
                             c <- allocs,
                             d <- allocs,
                             sum [a,b,c,d] == 1.0]
