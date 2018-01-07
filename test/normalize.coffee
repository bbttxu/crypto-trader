normalize = require '../lib/normalize'

should = require 'should'

describe 'normalize', ->
  it 'should normalize array', ->

    input = [ 0, 2, 1 ]

    expected = [ 0, 1, .5 ]

    normalize( input ).should.be.eql expected

