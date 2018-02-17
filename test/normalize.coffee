should = require 'should'

normalize = require '../lib/normalize'

describe 'normalize', ->
  it 'array', ->
    input = [ 1, 2, 3, 4 ]

    output = [
      0
      0.3333333333333333
      0.6666666666666666
      1
    ]

    normalize( input ).should.be.eql output
