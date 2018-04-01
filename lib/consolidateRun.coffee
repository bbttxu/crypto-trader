{
  head
  sum
  pluck
  last
} = require 'ramda'

uuid = require 'uuid'

statistics = require 'summary-statistics'

consolidateRun = ( run, product_id )->

  prices = statistics pluck 'price', run
  sizes = statistics pluck 'size', run
  times = statistics pluck 'timestamp', run

  return {
    _id: uuid.v4()
    product_id: product_id
    side: head( run ).side
    n: run.length
    volume: sizes.sum
    start: times.min
    end: times.max
    d_time: times.max - times.min
    d_price: last( run ).price - head( run ).price
    times: times
    prices: prices
    sizes: sizes
  }

module.exports = consolidateRun

