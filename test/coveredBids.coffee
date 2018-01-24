coveredBids = require '../lib/coveredBids'

should = require 'should'

describe 'coveredBids', ->
  it 'should provide most recent filled bids on sell', ->

    input = [
      side: 'sell'
      price: 13
      reason: 'canceled'
    ,
      side: 'sell'
      price: 5
      reason: 'filled'
    ,
      side: 'sell'
      price: 13
      reason: 'canceled'
    ,
      side: 'buy'
      price: 13
      reason: 'filled'
    ,
      side: 'buy'
      price: 12
      reason: 'canceled'
    ,
      side: 'sell'
      price: 13
      reason: 'filled'
    ,
      side: 'sell'
      price: 15
      reason: 'filled'
    ,
      side: 'sell'
      price: 16
      reason: 'canceled'
    ]

    expected = [
      side: 'sell'
      price: 13
      reason: 'filled'
    ,
      side: 'sell'
      price: 15
      reason: 'filled'
    ]


    output = coveredBids input, 'side'

    expected.should.be.eql output
