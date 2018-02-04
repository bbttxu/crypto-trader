should = require 'should'

arrayStats = require '../lib/arrayStats'

describe 'array stats', ->
  it 'returns stats on array of numbers', ->

    input = [
      1
      1
      2
      3
      5
      8
      11
    ]

    expected = {
      min: 1
      avg: 4.428571428571429
      max: 11
      n: 7
    }

    arrayStats( input ).should.be.eql expected


