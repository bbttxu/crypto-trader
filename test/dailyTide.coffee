should = require 'should'

dailyTide = require '../lib/dailyTide'

describe 'know a rising 24 hour trend', ->
  it 'DO sell if latest is higher than open', ->
    stats =
      open: 1
      latest: 2

    testBid = {
      side: 'sell'
    }

    decision = dailyTide stats, testBid
    decision.should.be.eql true

  it 'do NOT buy if latest is higher than open', ->
    stats =
      open: 1
      latest: 2

    testBid = {
      side: 'buy'
    }

    decision = dailyTide stats, testBid
    decision.should.be.eql false


describe 'know a declining 24 hour trend', ->
  it 'do NOT sell if latest is less than open', ->
    stats =
      open: 2
      latest: 1

    testBid = {
      side: 'sell'
    }

    decision = dailyTide stats, testBid
    decision.should.be.eql false


  it 'DO buy if latest is lower than open', ->
    stats =
      open: 2
      latest: 1

    testBid = {
      side: 'buy'
    }

    decision = dailyTide stats, testBid
    decision.should.be.eql true

describe 'when still', ->
  it 'encourages training', ->
    stats =
      open: 2
      latest: 2

    decision = dailyTide stats, undefined
    decision.should.be.eql true




