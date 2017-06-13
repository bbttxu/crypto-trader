require('dotenv').config { silent: true }

R = require 'ramda'
moment = require 'moment'
thunk = require 'redux-thunk'
deepEqual = require 'deep-equal'

gdax = require './lib/gdax-client'
currencySideRecent = require './lib/currencySideRecent'
saveFill = require './lib/saveFill'
savePosition = require './lib/savePosition'
Streams = require './lib/streams'

config = require './config'
ml = require './ml'

exit = require './lib/exit'

projectionMinutes = config.default.interval.value

console.log projectionMinutes

historicalMinutes = projectionMinutes * 5

reducers = require './reducers/reducer'

{ createStore, applyMiddleware } = require 'redux'

store = createStore reducers, applyMiddleware(thunk.default)


orderSuccess = ( response )->
  body = JSON.parse response.body
  if body.message
    console.log 'orderSuccess', response.body


orderFailed = ( order )->
  console.log 'orderFailed', order
  exit()

updatedStore = ->
  state = store.getState()

  keys = [ 'positions' ]
  important = R.pick keys, state
  console.log moment().format(), 'we got this', '$', important.positions.total.totalUSD.toFixed( 2 )

# store.subscribe updatedStore
setInterval updatedStore, 59 * 1000

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


clearOutOldOrders = ->
  state = store.getState()


  cancelOrder = ( order )->
    cancelOrderSuccess = ( response )->
      console.log 'cancelOrderSuccess', response, order.order_id
      store.dispatch
        type: 'ORDER_CANCELLED'
        order: order

    cancelOrderFailed = ( status )->
      # console.log 'cancelOrderFailed', status, order

    gdax.cancelOrder( order.order_id ).then( cancelOrderSuccess ).catch( cancelOrderFailed )

  tooOld = ( order )->
    # console.log order.time, moment( order.time ).isBefore moment().subtract( projectionMinutes, 'minutes' )
    moment( order.time ).isBefore moment().subtract( 864, 'seconds' )

  expired = R.filter tooOld, state.orders
  if expired.length > 0
    console.log 'cancel', R.pluck 'order_id', expired
    R.map cancelOrder, expired

clearOutOldOrders()
setInterval clearOutOldOrders, ( 864 * 1000 ) / 10

# Cancel All Orders, start with a clean slate
gdax.cancelAllOrders( R.keys config.currencies ).then (result)->
  console.log result


###
___________                  .___
\__    ___/___________     __| _/____   ______
  |    |  \_  __ \__  \   / __ |/ __ \ /  ___/
  |    |   |  | \// __ \_/ /_/ \  ___/ \___ \
  |____|   |__|  (____  /\____ |\___  >____  >
                      \/      \/    \/     \/
                      Trades
###

makeNewTrades = ->
  state = store.getState()

  keys = [ 'orders', 'proposals' ]
  important = R.pick keys, state
  # console.log moment().format(), JSON.stringify important

  predictionResults = R.values R.pick [ 'predictions' ], state

  bySide = ( trade )->
    trade.side

  sides = R.groupBy bySide, state.proposals

  console.log sides

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

setInterval makeNewTrades, ( 864 * 1000 ) / 10




universalBad = ( err )->
  console.log 'bad', err
  throw err if err
  exit()


###
   _____                                   __
  /  _  \   ____  ____  ____  __ __  _____/  |_
 /  /_\  \_/ ___\/ ___\/  _ \|  |  \/    \   __\
/    |    \  \__\  \__(  <_> )  |  /   |  \  |
\____|__  /\___  >___  >____/|____/|___|  /__|
        \/     \/    \/                 \/
        Update Account info
###

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
setInterval updateAccounts, 15 * 60 * 1000

#
saveAccountPositions = ->
  now = moment()

  # Get current position and timestamp it
  position = store.getState().positions
  position.time = now.toISOString()

  #
  savePosition( position ).then ( result )->
    console.log result, now.format()

#
setTimeout saveAccountPositions, 1 * 5 * 1000
setInterval saveAccountPositions, 15 * 60 * 1000



###
   _____          __         .__
  /     \ _____ _/  |_  ____ |  |__   ____   ______
 /  \ /  \\__  \\   __\/ ___\|  |  \_/ __ \ /  ___/
/    Y    \/ __ \|  | \  \___|   Y  \  ___/ \___ \
\____|__  (____  /__|  \___  >___|  /\___  >____  >
        \/     \/          \/     \/     \/     \/
###

Queue = require './lib/queue'
matchesQueue = Queue()

saveMatches = require './lib/saveMatches'

dispatchMatch = ( match, save = true )->
  store.dispatch
    type: 'ORDER_MATCHED'
    match: match

  matchesQueue.enqueue match if save

showSavedMatch = ( result )->
  info = JSON.stringify R.pick ['time','product_id','side','price','size', 'trade_id'], result
  console.log '+', info


asdfasdf = ->
  matches = matchesQueue.batch()

  if 0 isnt matches.length
    saveFillSuccess = ( results )->
      # since = moment( result.created_at ).fromNow( true )
      # R.map showSavedMatch, results

    saveFillFailure = ( err )->
      console.log 'errrrrrr asdfasdf', err
      matchesQueue.enqueue match
      exit()

    saveMatches( matches ).then( saveFillSuccess ).catch( saveFillFailure )

setInterval asdfasdf, 6000


sendHeartbeat = ->
  store.dispatch
    type: 'HEARTBEAT'
    message: moment().valueOf()

setInterval sendHeartbeat, 30 * 1000



channel = Streams R.keys config.currencies

channel.subscribe 'message', ( message )->

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


###
  ___ ___            .___              __
 /   |   \ ___.__. __| _/___________ _/  |_  ____
/    ~    <   |  |/ __ |\_  __ \__  \\   __\/ __ \
\    Y    /\___  / /_/ | |  | \// __ \|  | \  ___/
 \___|_  / / ____\____ | |__|  (____  /__|  \___  >
       \/  \/         \/            \/          \/
###

INTERVAL = 10

throttledDispatchMatch = (match, index)->
  sendThrottledDispatchMatch = ->

    # log it, but no need to save it
    dispatchMatch match, false

  setTimeout sendThrottledDispatchMatch, ( ( index * INTERVAL ) + ( Math.random() * INTERVAL ) )


hydrateRecentCurrency = ( product_id )->
  hydrateRecentCurrencySide = ( side )->
    # currencySideRecent( product_id, side, historicalMinutes, config.default.interval.units ).then ( matches )->
    currencySideRecent( product_id, side, 86400, 'seconds' ).then ( matches )->
      odd  = (v for v in matches by 2)
      even = (v for v in matches[1..] by 2)


      mapIndexed = R.addIndex R.map
      mapIndexed throttledDispatchMatch, odd.concat( R.reverse( even ) )


  R.map hydrateRecentCurrencySide, [ 'sell', 'buy' ]


waitAMoment = ->
  R.map hydrateRecentCurrency, R.keys config.currencies

setTimeout waitAMoment, 1000


###
  _________ __          __
 /   _____//  |______ _/  |_  ______
 \_____  \\   __\__  \\   __\/  ___/
 /        \|  |  / __ \|  |  \___ \
/_______  /|__| (____  /__| /____  >
        \/           \/          \/
###

updateStats = ->
  dispatchStats = ( results )->
    store.dispatch
      type: 'UPDATE_STATS'
      stats: R.mergeAll results

  gdax.stats( R.keys config.currencies ).then( dispatchStats )

updateStats()
setInterval updateStats, 30 * 1000




###
__________                             ___.
\______   \ ____   _____   ____   _____\_ |__   ___________
 |       _// __ \ /     \_/ __ \ /     \| __ \_/ __ \_  __ \
 |    |   \  ___/|  Y Y  \  ___/|  Y Y  \ \_\ \  ___/|  | \/
 |____|_  /\___  >__|_|  /\___  >__|_|  /___  /\___  >__|
        \/     \/      \/     \/      \/    \/     \/
###

saveFills = require './save'
setTimeout saveFills, 2000
setInterval saveFills, (1000 * 60 * 15)



process.on 'uncaughtException', (err) ->
  console.log 'Caught exception: ' + err



