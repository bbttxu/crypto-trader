should = require 'should'

goodSeaState = require '../lib/gooderSeaState'

describe 'know gooder seas', ->
  it 'DO sell higher than last buy', ->
    testBids = [
      id: 1
      side: 'buy'
      size: 1
      price: 100
      reason: 'filled'
      created_at: undefined
    ]

    testBid = {
      side: 'sell'
      size: 1
      price: 101

    }

    decision = goodSeaState testBids, testBid
    decision.should.be.eql true

  it 'DO buy lower than last sell', ->
    testBids = [
      id: 1
      side: 'sell'
      size: 1
      price: 100
      reason: 'filled'
      created_at: undefined
    ]

    testBid = {
      side: 'buy'
      size: 1
      price: 99
    }

    decision = goodSeaState testBids, testBid
    decision.should.be.eql true

describe 'know a bad sea', ->
  it 'do NOT sell lower than last buy', ->
    testBids = [
      id: 1
      side: 'buy'
      size: 1
      price: 100
      reason: 'filled'
      created_at: undefined
    ]

    testBid = {
      side: 'sell'
      size: 1
      price: 99

    }

    decision = goodSeaState testBids, testBid
    decision.should.be.eql false

  it 'do NOT buy higher than last sell', ->
  it 'buy lower than last sell', ->
    testBids = [
      id: 1
      side: 'sell'
      size: 1
      price: 100
      reason: 'filled'
      created_at: undefined
    ]

    testBid = {
      side: 'buy'
      size: 1
      price: 101
    }

    decision = goodSeaState testBids, testBid
    decision.should.be.eql false

  it 'handles no bids by encouraging trading', ->
    decision = goodSeaState [], undefined
    decision.should.be.eql true


  it 'handles undefined bid by not trading', ->
    decision = goodSeaState [ 'not', 'empty' ], undefined
    decision.should.be.eql false

  it 'handles not enough enough info on bid by not trading', ->
    decision = goodSeaState [ 'not', 'empty' ], {}
    decision.should.be.eql false


