should = require 'should'

denormalizeDatum = require '../lib/denormalizeDatum'

describe 'denormalize', ->
  it 'array', ->

    input =
      limits: [
        min: 1
        max: 4
      ,
        min: 2
        max: 5
      ,
        min: 3
        max: 6
      ,
        min: 4
        max: 7
      ]
      normalized: [
        [ 0, 0.3333333333333333, 0.6666666666666666, 1]
        [ 0, 0.3333333333333333, 0.6666666666666666, 1]
        [ 0, 0.3333333333333333, 0.6666666666666666, 1]
        [ 0, 0.3333333333333333, 0.6666666666666666, 1]
      ]

    output = [ [ 1, 2, 3, 4 ]
              [ 2, 3, 4, 5 ]
              [ 3, 4, 5, 6 ]
              [ 4, 5, 6, 7 ] ]


    denormalizeDatum( input ).should.be.eql output
