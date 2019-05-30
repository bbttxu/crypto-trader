normalize = require '../lib/normalizeVolume'

should = require 'should'

describe 'normalize volumes', ->
  it 'should normalize array', ->

    input =
      volume: 1
      volume_30day: 15

    expected = [ 1, .5 ]

    normalize( input ).should.be.eql expected

