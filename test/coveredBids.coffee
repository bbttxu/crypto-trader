coveredBids = require '../lib/coveredBids'

should = require 'should'

describe 'coveredBids', ->

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

  it 'should provide most recent filled bids on sell', ->
    expected = [
      side: 'sell'
      price: 13
      reason: 'filled'
    ,
      side: 'sell'
      price: 15
      reason: 'filled'
    ]


    output = coveredBids input, 'sell'

    expected.should.be.eql output


  it 'should provide most no filled bids on buy', ->
    expected = []

    output = coveredBids input, 'buy'

    expected.should.be.eql output
