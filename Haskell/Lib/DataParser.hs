module Lib.DataParser
  (
    readFrom
  ) where

import System.Locale
import Data.Time
import Data.Time.Format
import Data.List.Split
import Control.Monad.IO.Class
import Data.List
import QSTKUtil.Date

--params :: ticker, start date, end date
readFrom :: Day -> Day -> String -> IO [Double]
readFrom sd ed t =  do
                    all <- readFile ("Lib/Data/" ++ t ++ ".csv")
                    let prices =  zip dates (tail $ map last $ map (splitOn ",") $ lines all)
                                where dates = (tail $ map head $ map (splitOn ",") $ lines all)
                    let prices_from = map read $ map snd $ filter (\x -> parseStock (fst x) < ed && parseStock (fst x) >= sd) prices
                    return prices_from