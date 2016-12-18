
should = require 'should'

aggregate = require '../lib/aggregate'

describe 'aggregate', ->
  it 'returns empty on empty array', ->
    value = aggregate []

    emptyResult =
      volume: 0
      price: 0
      n: 0

    value.should.be.eql emptyResult

  it 'returns aggregate values for volume', ->
    values = [
      size: 0.1
      price: 0.01
    ,
      size: 0.1
      price: 0.01
    ,
      size: 0.1
      price: 0.01
    ]

    value = aggregate values

    expectedResult =
      volume: 0.3
      price: 0.0
      n: 3

    value.should.be.eql expectedResult

  it 'returns aggregate values for price drop', ->
    values = [
      size: 0.1
      price: 0.03
    ,
      size: 0.1
      price: 0.04
    ,
      size: 0.1
      price: 0.02
    ]

    value = aggregate values

    expectedResult =
      volume: 0.3
      price: -0.01
      n: 3

    value.should.be.eql expectedResult


  it 'returns aggregate values for price increase', ->
    values = [
      size: 0.1
      price: 0.02
    ,
      size: 0.1
      price: 0.04
    ,
      size: 0.1
      price: 0.03
    ]

    value = aggregate values

    expectedResult =
      volume: 0.3
      price: 0.01
      n: 3

    value.should.be.eql expectedResult
