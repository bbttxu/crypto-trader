should = require 'should'
{ createStore, applyMiddleware } = require 'redux'

reducer = require '../reducers/reducer'

describe 'reducer', ->
  it 'order matched', ->

    store = createStore reducer

    order =
      side: 'sell'
      product_id: 'ETH-BTC'
      trade_id: 1

    store.dispatch
      type: 'ORDER_MATCHED'
      match: order

    state = store.getState()

    expected =
      'ETH-BTC-SELL': [ order ]

    state.matches.should.be.eql expected


