require('dotenv').config { silent: true }

R = require 'ramda'
moment = require 'moment'
redux = require 'redux'
thunk = require 'redux-thunk'

gdax = require './lib/gdax-client'

predictions = require './lib/predictions'
proposals = require './lib/proposals'
currencySideRecent = require './lib/currencySideRecent'
saveFill = require './lib/saveFill'

config = require './config'
ml = require './ml'

projectionMinutes = 10
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
        state.sent.splice( index, 1 )


  if action.type is 'ORDER_FILLED'
    # console.log action.order
    client_oid = action.order.client_oid
    if client_oid
      index = R.findIndex(R.propEq('client_oid', client_oid))( state.orders )
      if index >= 0

        state.orders = state.orders.splice( index, 1 )

        getFills()

  if action.type is 'ORDER_CANCELLED'
    order_id = action.order.order_id
    console.log 'ORDER_CANCELLED', order_id
    if order_id
      index = R.findIndex(R.propEq('order_id', order_id))( state.orders )
      if index >= 0
        state.orders.splice( index, 1 )

  if action.type is 'ORDER_MATCHED'
    saveFillSuccess = ( result )->
      since = moment( result.created_at ).fromNow( true )
      if result is true
        console.log '$', since
      else
        console.log '+', since


    saveFill( action.match ).then( saveFillSuccess ).catch( universalBad )

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


orderSuccess = ( response )->
  body = JSON.parse response.body
  if body.message
    console.log 'orderSuccess', response.body


orderFailed = ( order )->
  console.log 'orderFailed', order


foo = ->
  state = store.getState()

  predictionResults = R.values R.pick [ 'predictions' ], state

  trades = proposals ( R.pick [ 'currencies' ], state ), predictionResults

  # console.log new Date(), trades

  bySide = ( trade )->
    trade.side

  sides = R.groupBy bySide, trades

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


setInterval foo, 60000

###
_________                            .__
\_   ___ \_____    ____   ____  ____ |  |
/    \  \/\__  \  /    \_/ ___\/ __ \|  |
\     \____/ __ \|   |  \  \__\  ___/|  |__
 \______  (____  /___|  /\___  >___  >____/
        \/     \/     \/     \/    \/
________            .___
\_____  \_______  __| _/___________  ______
 /   |   \_  __ \/ __ |/ __ \_  __ \/  ___/
/    |    \  | \/ /_/ \  ___/|  | \/\___ \
\_______  /__|  \____ |\___  >__|  /____  >
        \/           \/    \/           \/
###

cancelOrderFailed = ( order )->
  console.log 'orderFailed', order

clearOutOldOrders = ->
  state = store.getState()

  cancelOrder = ( order )->
    cancelOrderSuccess = ( response )->
      # console.log 'response', response.message

      store.dispatch
        type: 'ORDER_CANCELLED'
        order: order

      # if response.body
      #   body = JSON.parse response.body
      #   if body.message
      #     console.log 'orderSuccess', response.body
      # else
      #   console.log response


    gdax.cancelOrder( order.order_id ).then( cancelOrderSuccess ).catch( cancelOrderFailed )

  tooOld = ( order )->
    # console.log order.time, moment( order.time ).isBefore moment().subtract( projectionMinutes, 'minutes' )
    moment( order.time ).isBefore moment().subtract( projectionMinutes, 'minutes' )

  expired = R.filter tooOld, state.orders
  if expired.length > 0
    console.log 'cancel', R.pluck 'order_id', expired
    R.map cancelOrder, expired


setInterval clearOutOldOrders, 1000


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



###
  ___ ___            .___              __
 /   |   \ ___.__. __| _/___________ _/  |_  ____
/    ~    <   |  |/ __ |\_  __ \__  \\   __\/ __ \
\    Y    /\___  / /_/ | |  | \// __ \|  | \  ___/
 \___|_  / / ____\____ | |__|  (____  /__|  \___  >
       \/  \/         \/            \/          \/
###

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



###
__________                             ___.
\______   \ ____   _____   ____   _____\_ |__   ___________
 |       _// __ \ /     \_/ __ \ /     \| __ \_/ __ \_  __ \
 |    |   \  ___/|  Y Y  \  ___/|  Y Y  \ \_\ \  ___/|  | \/
 |____|_  /\___  >__|_|  /\___  >__|_|  /___  /\___  >__|
        \/     \/      \/     \/      \/    \/     \/
###

throttledDispatchFill = (match, index = 0)->
  # wereGood = (result)->

  #   since = moment( match.created_at ).fromNow( true )
  #   if result is true
  #     console.log '$', since
  #   else
  #     console.log '+', since

  # orNot = (result)->
  #   console.log 'orNot', result


  sendThrottledDispatchFill = ->
    dispatchMatch match

    # saveFill( match ).then( wereGood ).catch(orNot)

  setTimeout sendThrottledDispatchFill, ( ( index * INTERVAL ) + ( Math.random() * INTERVAL ) )


saveFills = ( fills )->
  mapIndexed = R.addIndex R.map
  mapIndexed throttledDispatchFill, R.reverse fills

cantSaveFills = ( fills )->
  console.log 'cantSaveFills', fills


getCurrencyFills = ( product_id )->
  gdax.getFills( product_id ).then( saveFills ).catch( cantSaveFills )


getFills = ->
  R.map getCurrencyFills, R.keys config.currencies

setTimeout getFills, 2000

# Cancel All Orders, start with a clean slate
gdax.cancelAllOrders( R.keys config.currencies ).then (result)->
  console.log result
