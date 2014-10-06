import QSTK.qstkutil.qsdateutil as du
import QSTK.qstkutil.tsutil as tsu
import QSTK.qstkutil.DataAccess as da

import datetime as dt
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
from itertools import *

def main():
  s_date = dt.datetime(2011, 1, 1)
  e_date = dt.datetime(2011, 12, 31)
  symbols = ["AAPL", "GOOG", "IBM", "MSFT"]
  data, timestamps = setup(s_date, e_date, symbols)
  optimal_alloc = best_port_from(symbols, data)
  port_rets, vol, daily_ret, sharpe, cum_ret = simulate(optimal_alloc, data)
  print "Start Date: %s" % s_date.strftime('%b %d, %Y')
  print "End Date: %s" % e_date.strftime('%b %d, %Y')
  print "Symbols: %s" % ', '.join(symbols)
  print "Optimal Allocation: %s" % (', '.join(str(x) for x in optimal_alloc))
  print "Sharpe Ratio: %f" % sharpe
  print "Volatility: %f" % vol
  print "Average Daily Return: %f" % daily_ret
  print "Cumulative Return: %f" % cum_ret
  spy_data, timestamps = setup(s_date, e_date, ["SPY"])
  spy_rets, vol, daily_ret, sharpe, cum_ret = simulate(optimal_alloc, spy_data)
  port_rets = list(chain.from_iterable(port_rets))
  spy_rets = list(chain.from_iterable(spy_rets))
  prices = zip(port_rets, spy_rets)
  create_plot(timestamps, prices)


def create_plot(dates, data):
  plt.clf()
  plt.plot(dates, data)
  plt.ylabel("Returns")
  plt.xlabel("Dates")
  plt.legend(["Port", "SPY"])
  plt.savefig("figure.pdf", format="pdf")

def setup(s_date, e_date, symbols):
  time_of_day = dt.timedelta(hours=16)
  timestamps = du.getNYSEdays(s_date, e_date, time_of_day)
  data = read_data(timestamps, symbols)
  return data, timestamps

def simulate(distro, data):
  prices = data['close'].values
  normal_prices = normalize(prices)
  adj_values = alloc_adj(normal_prices.copy(), distro)
  daily_values = daily_value(adj_values)
  daily_rets = tsu.daily(daily_values)

  volatility = np.std(daily_rets)
  sharpe = tsu.get_sharpe_ratio(daily_rets)[0]
  cum_ret = np.sum(daily_rets, axis=0)[0]
  avg_daily_ret = cum_ret / len(daily_rets)

  return daily_rets, volatility, avg_daily_ret, sharpe, (cum_ret + 1)


def best_port_from(symbols, data):
  max_sharpe = 0.0
  optimal_alloc = []
  distros = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]

  # generate all allocations
  allocs = product(distros, repeat=4)

  # filter out illegal allocations
  allocs = ifilter(lambda x: sum(x) == 1.0, allocs)

  for alloc in allocs:
    v, w, x, sharpe, z = simulate(alloc, data)
    if sharpe > max_sharpe:
      max_sharpe = sharpe
      optimal_alloc = alloc
  return optimal_alloc

def read_data(timestamps, symbols):
  dataobj = da.DataAccess('Yahoo', cachestalltime=0)
  key = ['close']
  all_data = dataobj.get_data(timestamps, symbols, key)
  return dict(zip(key, all_data))

def normalize(prices):
  return prices / prices[0, :]

def alloc_adj(returns, distro):
  for x in range(len(returns[0])):
    for y in range(len(returns)):
      returns[y][x] *= distro[x]
  return returns

def daily_value(prices):
  daily_values = []
  for x in range(len(prices)):
    sum = 0
    for y in range(len(prices[0])):
      sum += prices[x][y]
    daily_values.append(sum)

  return daily_values

if __name__ == "__main__":
  main()
