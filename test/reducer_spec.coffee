should = require 'should'
moment = require 'moment'
{ createStore, applyMiddleware } = require 'redux'

reducer = require '../reducers/reducer'

describe 'reducer', ->
  it 'order matched, price updated', ->

    store = createStore reducer

    order =
      side: 'sell'
      product_id: 'ETH-BTC'
      trade_id: 1
      price: '0.0008'

    store.dispatch
      type: 'ORDER_MATCHED'
      match: order

    state = store.getState()

    expectedMatches =
      'ETH-BTC-SELL': [ order ]

    state.matches.should.be.eql expectedMatches

    expectedPrices =
      'ETH-BTC-SELL':
        price: '0.0008'

    state.prices.should.be.eql expectedPrices


  it 'order matched, old order removed', ->

    initialState =
      orders: [
        side: 'buy'
        product_id: 'ETH-BTC'
        trade_id: 1
        price: '0.0008'
        time: moment().subtract(1, 'hour').format()
      ]
      matches: {}
      prices: {}
      predictions: {}

    store = createStore reducer, initialState

    order =
      side: 'buy'
      product_id: 'ETH-BTC'
      trade_id: 2
      price: '0.0009'

    store.dispatch
      type: 'ORDER_MATCHED'
      match: order

    state = store.getState()

    expectedMatches =
      'ETH-BTC-BUY': [ order ]

    state.matches.should.be.eql expectedMatches


