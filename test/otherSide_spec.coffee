should = require 'should'

otherSide = require '../lib/otherSide'

describe 'otherSide', ->
  it 'knows that a sell is not a buy', ->
    otherSide( 'sell' ).should.be.eql 'buy'

  it 'knows that a buy is not a sell', ->
    otherSide( 'buy' ).should.be.equal 'sell'

  it 'knows to not care about something that is not a sell or buy', ->
    should.not.exist otherSide( 'asdf' )
