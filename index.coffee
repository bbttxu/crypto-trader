require('dotenv').config { silent: true }

R = require 'ramda'
moment = require 'moment'
thunk = require 'redux-thunk'

gdax = require './lib/gdax-client'

proposals = require './lib/proposals'
currencySideRecent = require './lib/currencySideRecent'
saveFill = require './lib/saveFill'

config = require './config'
ml = require './ml'

projectionMinutes = config.default.interval.value
historicalMinutes = projectionMinutes * 3

reducers = require './reducers/reducer'

{ createStore, applyMiddleware } = require 'redux'

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
    moment( order.time ).isBefore moment().subtract( projectionMinutes, config.default.interval.units )

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

    # if message.type is 'received'
    #   store.dispatch
    #     type: 'ORDER_RECEIVED'
    #     order: message

    # if message.type is 'done' and message.reason is 'filled'
    #   store.dispatch
    #     type: 'ORDER_FILLED'
    #     order: message


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
    currencySideRecent( product_id, side, historicalMinutes, config.default.interval.units ).then ( matches )->
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
    store.dispatch
      type: 'HISTORICAL_MATCH'
      match: match

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

process.on 'uncaughtException', (err) ->
  console.log 'Caught exception: ' + err
