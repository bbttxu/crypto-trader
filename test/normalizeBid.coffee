normalizeBid = require '../lib/normalizeBid'

should = require 'should'

describe 'normalize bid', ->
  it 'should normalize bid object', ->

    input =
      open: '952.38000000'
      high: '1009.11000000'
      low: '950.00000000'
      volume: '128231.92639216'
      last: '1005.09000000'
      volume_30day: '9211034.96161294'

    expected = [
      0.41764663881931036,
      1,
      0.931991202842159,
      0.0402639147352393
    ]

    normalizeBid( input ).should.be.eql expected

