should = require 'should'
R = require 'ramda'

cleanUpTrade = require '../lib/cleanUpTrades'

describe 'cleanUpTrades', ->
  it 'calculates spread on increase, BTC-USD', ->
    input =
      size: 0.902938432
      side: 'sell'
      price:  875.3456
      product_id: 'BTC-USD'

    output =
      size: '0.9029'
      side: 'sell'
      price:  '875.35'
      product_id: 'BTC-USD'

    result = R.pick ['size', 'side', 'price', 'product_id'], cleanUpTrade input
    result.should.be.eql output


  it 'calculates spread on decrease, BTC-USD', ->
    input =
      size: 0.902938432
      side: 'buy'
      price:  875.3456
      product_id: 'BTC-USD'

    output =
      size: '0.9029'
      side: 'buy'
      price:  '875.34'
      product_id: 'BTC-USD'

    result = R.pick ['size', 'side', 'price', 'product_id'], cleanUpTrade input
    result.should.be.eql output

  it 'calculates spread on increase, ETH-BTC', ->
    input =
      size: 0.902938432
      side: 'sell'
      price:  0.902938432
      product_id: 'ETH-BTC'

    output =
      size: '0.9029'
      side: 'sell'
      price:  '0.90294'
      product_id: 'ETH-BTC'

    result = R.pick ['size', 'side', 'price', 'product_id'], cleanUpTrade input
    result.should.be.eql output


  it 'calculates spread on decrease, ETH-BTC', ->
    input =
      size: 0.902938432
      side: 'buy'
      price:  0.902938432
      product_id: 'ETH-BTC'

    output =
      size: '0.9029'
      side: 'buy'
      price:  '0.90293'
      product_id: 'ETH-BTC'

    result = R.pick ['size', 'side', 'price', 'product_id'], cleanUpTrade input
    result.should.be.eql output

  it 'keeps uuid when present', ->
    input =
      product_id: 'ETH-BTC'
      client_oid: 'foo'

    cleanUpTrade( input ).should.be.eql input


  it 'applies uuid when not present', ->
    input =
      product_id: 'ETH-BTC'

    cleanUpTrade( input ).client_oid.should.exist
