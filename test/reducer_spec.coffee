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
      currencies:
        BTC:
          available: 1.0
          hold: 1.0
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


  it 'order sent, buy LTC decreases USD balance', ->

    initialState =
      sent: []
      currencies:
        USD:
          balance: 1.0
          hold: 1.0

    store = createStore reducer, initialState

    order =
      client_oid: 'abcdefgh'
      size: '0.10000'
      side: 'buy'
      product_id: 'LTC-USD'

    store.dispatch
      type: 'ORDER_SENT'
      order: order

    state = store.getState()

    expectedSent = [ order ]

    state.sent.should.be.eql expectedSent

    state.currencies.USD.balance.should.be.eql '0.9000'

    state.currencies.USD.hold.should.be.eql '1.1000'



  it 'order sent, sell BTC decreases ETH balance', ->

    initialState =
      sent: []
      currencies:
        BTC:
          balance: 1.0
          hold: 1.0

    store = createStore reducer, initialState

    order =
      client_oid: 'abcdefgh'
      size: '0.50000'
      side: 'buy'
      product_id: 'ETH-BTC'

    store.dispatch
      type: 'ORDER_SENT'
      order: order

    state = store.getState()

    expectedSent = [ order ]

    state.sent.should.be.eql expectedSent

    state.currencies.BTC.balance.should.be.eql '0.5000'

    state.currencies.BTC.hold.should.be.eql '1.5000'



  it 'order received', ->

    order =
      client_oid: 'abcdefgh'

    initialState =
      sent: [ order ]
      orders: []

    store = createStore reducer, initialState

    store.dispatch
      type: 'ORDER_RECEIVED'
      order: order

    state = store.getState()

    expectedOrders = [ order ]

    state.sent.length.should.be.eql 0
    state.orders.should.be.eql expectedOrders


  it 'order canceled', ->

    order =
      order_id: 'bcdefghi'

    initialState =
      orders: [ order ]

    store = createStore reducer, initialState

    store.dispatch
      type: 'ORDER_CANCELLED'
      order: order

    state = store.getState()

    state.orders.length.should.be.eql 0


  it 'order filled', ->

    order =
      order_id: 'cdefghij'

    initialState =
      orders: [ order ]

    store = createStore reducer, initialState

    store.dispatch
      type: 'ORDER_FILLED'
      order: order

    state = store.getState()

    state.orders.length.should.be.eql 0
