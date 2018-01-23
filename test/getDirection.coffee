getDirection = require '../lib/getDirection'

should = require 'should'

describe 'it determines direction', ->
  it 'shows sell on increase', ->

    input =
      latest: 2
      open: 1

    output = getDirection input

    output.should.be.eql 'sell'


  it 'shows buy on decrease', ->

    input =
      latest: 1
      open: 2

    output = getDirection input

    output.should.be.eql 'buy'


  it 'passes present state if equal', ->

    input =
      latest: 2
      open: 2

    output = getDirection input, 'test'

    output.should.be.eql 'test'
