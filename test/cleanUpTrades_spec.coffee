should = require 'should'

cleanUpTrade = require '../lib/cleanUpTrades'

describe 'cleanUpTrades', ->
  it 'calculates spread on increase', ->
    input =
      size: 0.902938432
      side: 'sell'
      price:  875.3456
      product_id: 'BTC-USD'

    output =
      size: '0.90293843'
      side: 'sell'
      price:  '875.35'
      product_id: 'BTC-USD'

    result = cleanUpTrade input
    result.should.be.eql output


  it 'calculates spread on decrease', ->
    input =
      size: 0.902938432
      side: 'buy'
      price:  875.3456
      product_id: 'BTC-USD'

    output =
      size: '0.90293843'
      side: 'buy'
      price:  '875.34'
      product_id: 'BTC-USD'

    result = cleanUpTrade input
    result.should.be.eql output

