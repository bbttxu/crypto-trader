should = require 'should'

normalizeDatum = require '../lib/normalizeDatum'

describe 'normalize datum' , ->
  it 'array of arrays', ->
    input = [ [ 1, 3, 5, 28 ]
              [ 2, 6, 10, 21 ]
              [ 3, 9, 15, 7 ]
              [ 4, 12, 20, 14 ] ]

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
        [ 1, 0.6666666666666666, 0, 0.3333333333333333, ]
      ]

    # console.log normalizeDatum( input )
    normalizeDatum( input ).should.be.eql output


  it 'a single array', ->
    input = [ [ 1 ]
              [ 2 ]
              [ 3 ]
              [ 4 ] ]

    output =
      limits: [
        min: 1
        max: 4
      ]

      normalized: [
        [ 0, 0.3333333333333333, 0.6666666666666666, 1]
      ]

    # console.log normalizeDatum( input )
    normalizeDatum( input ).should.be.eql output
