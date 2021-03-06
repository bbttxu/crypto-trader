require('dotenv').config { silent: true }

Gdax = require 'gdax'

{
  getProduct24HrStats
} = require './lib/gdax-client'

authentication =
  secret: process.env.API_SECRET
  key: process.env.API_KEY
  passphrase: process.env.API_PASSPHRASE

shuffle = require('knuth-shuffle').knuthShuffle

Redis = require 'ioredis'

exit = require './lib/exit'

log = require './lib/log'

{
  isEmpty
  forEach
  pick
  keys
  map
  addIndex
  forEachObjIndexed
  sum
  takeLast
  clamp
  isNil
} = require 'ramda'

pub = new Redis()

config = require './config'

currencies = keys config.currencies

websocket = new Gdax.WebsocketClient( currencies, null, authentication )

websocket.on 'open', ->
  log "OPENED #{currencies} WEBSOCKET!!!"

websocket.on 'close', ->
  log "CLOSED #{currencies} WEBSOCKET!!!"
  exit( -1 )

websocket.on 'message', (message)->
  pub.publish "feed:#{message.product_id}", JSON.stringify message



catchError = ( name )->
  ( error )->
    log name, error.response.data.message



accountChannel = new Redis()

{
  getAccounts
  stat
} = require './lib/gdax-client'

accounts = []

updateAccountinfo = ->
  getAccounts().then(
    ( results )->
      if not isEmpty results
        if isNil results.message
          accounts = results

  ).catch(
    catchError( 'accounts' )
  )

updateAccountinfo()
setInterval updateAccountinfo, 60 * 1000

publishAccountInfo = ->
  accountChannel.publish "accounts", JSON.stringify map pick( ['currency', 'available', 'hold', 'balance'] ), accounts

publishAccountInfo()
setInterval publishAccountInfo, 6 * 1000



candlesChannel = new Redis()



###
use candles to gauge where things are trending
###

# candleSpacings = []

# addCandleSpacing = ( spacing )->
#   candleSpacings.push spacing
#   candleSpacings = takeLast 50, candleSpacings


# candleSpacing = ( index = 1 )->
#   clamp(
#     1000
#     6000
#     ( sum( candleSpacings ) / candleSpacings.length || 3000 )
#   ) * index


# inTheWind = require './lib/inTheWind'

# # https://docs.gdax.com/#get-historic-rates
# normaJean = ( product_id, index = 1 )->
#   doIt = ->
#     start = Date.now()

#     stat(
#       product_id
#     ).then(
#       inTheWind
#     ).then(
#       ( factors )->
#         log product_id, 'norma jean', Date.now() - start, 'ms'

#         addCandleSpacing Date.now() - start

#         log 'avg', candleSpacings.length, sum( candleSpacings ) / candleSpacings.length, 'ms'

#         unless isNil factors.message
#           candlesChannel.publish "factors:#{product_id}", JSON.stringify factors

#     ).catch(
#       catchError( 'candles' )
#     )

#   setTimeout doIt, candleSpacing( index )


# getCandles = ->
#   addIndex( forEach ) normaJean, currencies


# setInterval(
#   getCandles,
#   30 * 1000
# )
# getCandles()





statsChannel = new Redis()

statsChannelReducer = require './reducers/statsChannelReducer'

{ createStore, applyMiddleware } = require 'redux'
thunk = require 'redux-thunk'

store = createStore statsChannelReducer, applyMiddleware(thunk.default)

updateStat = ( product_id, index = 1 )->
  doIt = ->
    getProduct24HrStats(
      product_id
    ).then(
      ( stats )->
        store.dispatch
          type: 'UPDATE'
          stats: stats
          product_id: product_id

    ).catch(
      catchError( "stats #{product_id}" )
    )

  setTimeout doIt, index * 3000

updateStats = ->
  addIndex( forEach ) updateStat, shuffle currencies



setInterval updateStats, 60 * 1000
updateStats()


updateStatsFeed = ( stats, product_id )->
  statsChannel.publish "stats:#{product_id}", JSON.stringify stats

store.subscribe ->
  state = store.getState()
  forEachObjIndexed updateStatsFeed, store.getState()

