should = require 'should'

groupBySide = require '../lib/groupBySide'

describe 'array stats', ->
  it 'returns self with empty array', ->
    groupBySide( [] ).should.be.eql {}


  it 'returns stats on array of numbers', ->

    input = [
      side: 'sell'
      value: 'a'
    ,
      side: 'buy'
      value: 'b'
    ,
      side: 'sell'
      value: 'c'
    ]

    expected =
      sell: [
        side: 'sell'
        value: 'a'
      ,
        side: 'sell'
        value: 'c'
      ]
      buy: [
        side: 'buy'
        value: 'b'
      ]

    groupBySide( input ).should.be.eql expected



