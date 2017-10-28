should = require 'should'

goodSeaState = require '../lib/goodSeaState'


describe 'know a good sea', ->
  it 'sell higher than last buy', ->
    state = {
      match: {
        side: 'sell'
      }
      sell: {
        d_time: 6475,
        d_price: 1.4752173913043605,
        d_volume: 1.3774999973913045,
        n: 186,
        n_runs: 23,
        n_runs_ratio: 8.08695652173913,
        price: '5858.58000000',
        sequence: 4279693895,
        bid: {
          price: '5862.99',
          side: 'sell',
          product_id: 'BTC-USD',
          size: '0.0012',
          client_oid: '77920a6d-5f9f-4690-bbbe-0aa9d4dcce87' }
        },
      fills: [
        {
          side: 'buy'
          price: '5862.00'
        }
      ]
    }
    decision = goodSeaState state
    decision.should.be.eql true

  it 'buy lower than last sell', ->
    state = {
      match: {
        side: 'buy'
      }
      buy: {
        d_time: 6475,
        d_price: 1.4752173913043605,
        d_volume: 1.3774999973913045,
        n: 186,
        n_runs: 23,
        n_runs_ratio: 8.08695652173913,
        price: '5858.58000000',
        sequence: 4279693895,
        bid: {
          price: '5861.99',
          side: 'buy',
          product_id: 'BTC-USD',
          size: '0.0012',
          client_oid: '77920a6d-5f9f-4690-bbbe-0aa9d4dcce87' }
        },
      fills: [
        {
          side: 'sell'
          price: '5862.00'
        }
      ]
    }
    decision = goodSeaState state
    decision.should.be.eql true

describe 'know a bad sea', ->
  it 'do not sell lower than last buy', ->
    state = {
      match: {
        side: 'sell'
      }
      sell: {
        d_time: 6475,
        d_price: 1.4752173913043605,
        d_volume: 1.3774999973913045,
        n: 186,
        n_runs: 23,
        n_runs_ratio: 8.08695652173913,
        price: '5858.58000000',
        sequence: 4279693895,
        bid: {
          price: '5862.00',
          side: 'sell',
          product_id: 'BTC-USD',
          size: '0.0012',
          client_oid: '77920a6d-5f9f-4690-bbbe-0aa9d4dcce87' }
        },
      fills: [
        {
          side: 'buy'
          price: '5862.99'
        }
      ]
    }
    decision = goodSeaState state
    decision.should.be.eql false

  it 'do not buy higher than last sell', ->
    state = {
      match: {
        side: 'buy'
      }
      buy: {
        d_time: 6475,
        d_price: 1.4752173913043605,
        d_volume: 1.3774999973913045,
        n: 186,
        n_runs: 23,
        n_runs_ratio: 8.08695652173913,
        price: '5858.58000000',
        sequence: 4279693895,
        bid: {
          price: '5861.99',
          side: 'buy',
          product_id: 'BTC-USD',
          size: '0.0012',
          client_oid: '77920a6d-5f9f-4690-bbbe-0aa9d4dcce87' }
        },
      fills: [
        {
          side: 'sell'
          price: '5861.00'
        }
      ]
    }
    decision = goodSeaState state
    decision.should.be.eql false



