{
  head
  sum
  pluck
  last
} = require 'ramda'

consolidateRun = ( run, product_id )->
  return {
    product_id: product_id
    side: head( run ).side
    n: run.length
    volume: sum pluck 'size', run
    start: head( run ).timestamp
    end: last( run ).timestamp
    d_time: last( run ).timestamp - head( run ).timestamp
    d_price: last( run ).price - head( run ).price
  }

module.exports = consolidateRun

