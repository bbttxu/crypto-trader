coveredPrice = require '../lib/coveredPrice'

should = require 'should'

describe 'coveredPrice should cover price', ->
  it 'in sell direction', ->

    input = [
      side: 'sell'
      price: 13
    ,
      side: 'sell'
      price: 12
    ,
      side: 'sell'
      price: 13
    ,
      side: 'sell'
      price: 15
    ,
      side: 'sell'
      price: 16
    ,
      side: 'sell'
      price: 15
    ,
      side: 'sell'
      price: 13
    ,
      side: 'sell'
      price: 15
    ]

    expected = 12

    output = coveredPrice input

    expected.should.be.eql output


  it 'in buy direction', ->

    input = [
      side: 'buy'
      price: 13
    ,
      side: 'buy'
      price: 12
    ,
      side: 'buy'
      price: 13
    ,
      side: 'buy'
      price: 15
    ,
      side: 'buy'
      price: 16
    ,
      side: 'buy'
      price: 15
    ,
      side: 'buy'
      price: 13
    ,
      side: 'buy'
      price: 15
    ]

    expected = 16

    output = coveredPrice input

    expected.should.be.eql output


  it 'in unknown direction', ->
    should.not.exist coveredPrice []


