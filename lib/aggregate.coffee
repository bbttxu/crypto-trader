R = require 'ramda'

pricing = require './pricing'

emptyAggregate =
  volume: 0
  price: 0
  n: 0

aggregate = ( trades )->

  return emptyAggregate if trades.length is 0
  # Volume is the sum of all sizes of all trades
  volume = parseFloat pricing.btc R.sum R.pluck 'size', trades

  # Price change is the difference from first to last
  prices = R.pluck 'price', trades
  firstPrice = R.take(1)(prices)[0]
  lastPrice = R.last(prices)

  # Price change is greater than the threshold
  priceSignal = parseFloat pricing.usd ( lastPrice - firstPrice )

  aggregates =
    volume: volume
    price: priceSignal
    n: trades.length

module.exports = aggregate
