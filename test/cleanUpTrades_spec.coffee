should = require 'should'

cleanUpTrade = require '../lib/cleanUpTrades'

describe 'cleanUpTrades', ->
  it 'calculates spread on increase, BTC-USD', ->
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


  it 'calculates spread on decrease, BTC-USD', ->
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

  it 'calculates spread on increase, ETH-BTC', ->
    input =
      size: 0.902938432
      side: 'sell'
      price:  0.902938432
      product_id: 'ETH-BTC'

    output =
      size: '0.90293843'
      side: 'sell'
      price:  '0.90293844'
      product_id: 'ETH-BTC'

    result = cleanUpTrade input
    result.should.be.eql output


  it 'calculates spread on decrease, ETH-BTC', ->
    input =
      size: 0.902938432
      side: 'buy'
      price:  0.902938432
      product_id: 'ETH-BTC'

    output =
      size: '0.90293843'
      side: 'buy'
      price:  '0.90293843'
      product_id: 'ETH-BTC'

    result = cleanUpTrade input
    result.should.be.eql output
