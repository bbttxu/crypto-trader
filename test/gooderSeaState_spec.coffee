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

  # it 'handles no fills', ->
  #   testState =
  #     match: side: 'buy'
  #     buy:
  #       d_time: 6475
  #       d_price: 1.4752173913043605
  #       d_volume: 1.3774999973913045
  #       n: 186
  #       n_runs: 23
  #       n_runs_ratio: 8.08695652173913
  #       price: '5858.58000000'
  #       sequence: 4279693895
  #       bid:
  #         price: '5861.99'
  #         side: 'buy'
  #         product_id: 'BTC-USD'
  #         size: '0.0012'
  #         client_oid: '77920a6d-5f9f-4690-bbbe-0aa9d4dcce87'
  #     fills: []

  #   decision = goodSeaState testState
  #   decision.should.be.eql false




