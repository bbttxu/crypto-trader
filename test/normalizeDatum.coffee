should = require 'should'

normalizeDatum = require '../lib/normalizeDatum'

describe 'normalize', ->
  it 'array', ->
    input = [ [ 1, 3, 5, 7 ]
              [ 2, 6, 10, 14 ]
              [ 3, 9, 15, 21 ]
              [ 4, 12, 20, 28 ] ]

    output =
      limits: [
        min: 1
        max: 4
      ,
        min: 3
        max: 12
      ,
        min: 5
        max: 20
      ,
        min: 7
        max: 28
      ]
      normalized: [
        [ 0, 0.3333333333333333, 0.6666666666666666, 1]
        [ 0, 0.3333333333333333, 0.6666666666666666, 1]
        [ 0, 0.3333333333333333, 0.6666666666666666, 1]
        [ 0, 0.3333333333333333, 0.6666666666666666, 1]
      ]

    normalizeDatum( input ).should.be.eql output
