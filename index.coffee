require('dotenv').config( silent: true )

R = require 'ramda'
moment = require 'moment'
redux = require 'redux'
thunk = require 'redux-thunk'

gdax = require './lib/gdax-client'

predictions = require './lib/predictions'
proposals = require './lib/proposals'
currencySideRecent = require './lib/currencySideRecent'

config = require './config'
ml = require './ml'

projectionMinutes = 5
historicalMinutes = projectionMinutes * 3



{ createStore, applyMiddleware } = require 'redux'

initalState =
  currencies: {}
  prices: {}
  predictions: {}
  matches: {}

  sent: []
  orders: []

reducers = (state, action) ->

  if typeof state == 'undefined'
    return initalState

  if action.type is 'UPDATE_ACCOUNT'
    state.currencies[action.currency.currency] = R.pick ['hold', 'balance'], action.currency

  if action.type is 'ORDER_SENT'
    # console.log 'ORDER_SENT', action.order
    state.sent.push action.order

  if action.type is 'ORDER_RECEIVED'
    client_oid = action.order.client_oid
    if client_oid
      index = R.findIndex(R.propEq('client_oid', client_oid))( state.sent)
      if index >= 0
        state.orders.push action.order
        state.sent = state.sent.splice( index, 1 )


  if action.type is 'ORDER_FILLED'
    client_oid = action.order.client_oid
    if client_oid
      index = R.findIndex(R.propEq('client_oid', client_oid))( state.orders )
      if index >= 0

        state.orders.push action.order
        state.orders = state.sent.splice( index, 1 )

  # if action.type is 'ORDER_CANCELLED'
  #   console.log 'ORDER_CANCELLED'

  if action.type is 'ORDER_MATCHED'
    # console.log 'ORDER_MATCHED', action.match
    key = [ action.match.product_id, action.match.side ].join( '-' ).toUpperCase()

    state.prices[key] = R.pick [ 'time', 'price'], action.match

    unless state.matches[key]
      state.matches[key] = []

    state.matches[key].push action.match

    byTime = ( doc )->
      moment( doc.time ).valueOf()

    tooOld = ( doc )->
      cutoff = moment().subtract historicalMinutes, 'minute'
      moment( doc.time ).isBefore cutoff

    state.matches[key] = R.reject tooOld, R.sortBy byTime, state.matches[key]

    future = moment().add( projectionMinutes, 'minute' ).utc().unix()
    predictor = predictions action.match.side, future, key

    state.predictions[key] = predictor state.matches[key]

  state

store = createStore reducers, applyMiddleware(thunk.default)

# store.subscribe (foo)->
#   state = store.getState()

#   console.log R.pick ['sent', 'orders'], state

  # state = store.getState()

  # console.log new Date()

  # predictionResults = R.values R.pick [ 'predictions' ], state

  # trades = proposals ( R.pick [ 'currencies' ], state ), predictionResults



  # console.log new Date(), trades

  # bySide = ( trade )->
  #   trade.side

  # sides = R.groupBy bySide, trades

  # console.log sides


foo = ->
  state = store.getState()

  predictionResults = R.values R.pick [ 'predictions' ], state

  trades = proposals ( R.pick [ 'currencies' ], state ), predictionResults

  console.log new Date(), trades

  bySide = ( trade )->
    trade.side

  sides = R.groupBy bySide, trades

  # console.log sides

  orderSuccess = ( response )->
    body = JSON.parse response.body
    if body.message
      console.log 'orderSuccess', response.body

  orderFailed = ( order )->
    console.log 'orderFailed', order

  sellOrder = ( order )->
    store.dispatch
      type: 'ORDER_SENT'
      order: order

    gdax.sell( order ).then( orderSuccess ).catch( orderFailed )

  buyOrder = ( order )->
    store.dispatch
      type: 'ORDER_SENT'
      order: order

    gdax.buy( order ).then( orderSuccess ).catch( orderFailed )


  if sides.sell
    R.map sellOrder, sides.sell

  if sides.buy
    R.map buyOrder, sides.buy

  # console.log R.pick [ 'orders', 'sent' ], state


  cancelOrder = ( order )->

    store.dispatch
      type: 'ORDER_CANCELLED'
      order: order

    gdax.cancelOrder( order.order_id ).then( orderSuccess ).catch( orderFailed )

  tooOld = ( order )->
    # console.log order.time, moment( order.time ).isBefore moment().subtract( projectionMinutes, 'minutes' )
    moment( order.time ).isBefore moment().subtract( projectionMinutes, 'minutes' )

  expired = R.filter tooOld, state.orders

  R.map cancelOrder, expired


setInterval foo, 60000


universalBad = ( err )->
  console.log 'bad', err
  throw err if err




# Update Account info


getRelevantCurrencies = ( currencyPairs )->
  split = ( currencyPair )->
    currencyPair.split '-'

  R.uniq R.flatten R.map split, currencyPairs


showAccounts = ( results )->
  currentlyTradedCurrencies = getRelevantCurrencies R.keys config.currencies

  currentlyTraded = ( result )->
    R.contains result.currency, currentlyTradedCurrencies

  dispatchCurrencyBalance = ( currency )->

    store.dispatch
      type: 'UPDATE_ACCOUNT'
      currency: currency

  R.map dispatchCurrencyBalance, R.map R.pick([ 'currency', 'hold', 'balance' ]), R.filter currentlyTraded, results

updateAccounts = ->
  gdax.getAccounts().then( showAccounts )

updateAccounts()
setInterval updateAccounts, 59 * 60 * 1000



dispatchMatch = ( match )->
  store.dispatch
    type: 'ORDER_MATCHED'
    match: match



# Update on matches
Gdax = require 'gdax'
# websocket = new Gdax.WebsocketClient()
# websocket.on 'message', (data)->
#   console.log data


Gdax = require('gdax')
authentication =
  secret: process.env.API_SECRET
  key: process.env.API_KEY
  passphrase: process.env.API_PASSPHRASE

# websocket = new (Gdax.WebsocketClient)(null, null, authentication)
# websocket.on 'message', (data) ->
#   console.log data

currencyStream = (product)->
  # console.log 'stream', product
  stream = new (Gdax.WebsocketClient)(product, null, authentication)

  stream.on 'error', (foo)->

    console.log 'error'
    console.log foo


  stream.on 'message', ( message )->
    if message.type is 'match'
      dispatchMatch message

    if message.type is 'received'
      store.dispatch
        type: 'ORDER_RECEIVED'
        order: message

    if message.type is 'done' and message.reason is 'filled'
      store.dispatch
        type: 'ORDER_FILLED'
        order: message


R.map currencyStream, R.keys config.currencies



INTERVAL = 100

throttledDispatchMatch = (match, index)->
  sendThrottledDispatchMatch = ->
    console.log '*', moment( match.time ).fromNow( true )
    dispatchMatch match

  setTimeout sendThrottledDispatchMatch, ( ( index * INTERVAL ) + ( Math.random() * INTERVAL ) )


hydrateRecentCurrency = ( product_id )->
  hydrateRecentCurrencySide = ( side )->
    currencySideRecent( product_id, side, historicalMinutes, 'minute' ).then ( matches )->
      mapIndexed = R.addIndex R.map
      mapIndexed throttledDispatchMatch, R.reverse matches


  R.map hydrateRecentCurrencySide, [ 'sell', 'buy' ]


waitAMoment = ->
  R.map hydrateRecentCurrency, R.keys config.currencies

setTimeout waitAMoment, 1000



