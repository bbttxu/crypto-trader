normalize = require '../lib/normalizePrices'

should = require 'should'

describe 'normalize prices', ->
  it 'should normalize array', ->

    input =
      low: 1
      high: 2
      open: 1.5
      last: 1.75

    expected = [ 0.75, 0.5 ]

    normalize( input ).should.be.eql expected

