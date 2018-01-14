require('dotenv').config { silent: true }

Gdax = require 'gdax'

authentication =
  secret: process.env.API_SECRET
  key: process.env.API_KEY
  passphrase: process.env.API_PASSPHRASE


Redis = require 'ioredis'

exit = require './lib/exit'

{
  isEmpty
  forEach
  pick
  keys
  map
  addIndex
} = require 'ramda'

pub = new Redis()

config = require './config'

currencies = keys config.currencies

websocket = new Gdax.WebsocketClient( currencies, null, authentication )

websocket.on 'open', ->
  console.log "OPENED #{currencies} WEBSOCKET!!!"

websocket.on 'close', ->
  console.log "CLOSED #{currencies} WEBSOCKET!!!"
  exit( -1 )

websocket.on 'message', (message)->
  pub.publish "feed:#{message.product_id}", JSON.stringify message



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
        accounts = results
  )

updateAccountinfo()
setInterval updateAccountinfo, 30 * 1000

publishAccountInfo = ->
  accountChannel.publish "accounts", JSON.stringify map pick( ['currency', 'available', 'hold', 'balance'] ), accounts

publishAccountInfo()
setInterval publishAccountInfo, 6 * 1000



candlesChannel = new Redis()



###
use candles to gauge where things are trending
###

inTheWind = require './lib/inTheWind'

# https://docs.gdax.com/#get-historic-rates
normaJean = ( product_id, index = 1 )->
  doIt = ->
    stat(
      product_id
    ).then(
      inTheWind
    ).then(
      ( factors )->
        candlesChannel.publish "factors:#{product_id}", JSON.stringify factors

    ).catch(
      ( error )->
        console.log 'candles error', error
    )

  setTimeout doIt, index * 1000


getCandles = ->
  addIndex( forEach ) normaJean, currencies


setInterval(
  getCandles,
  30 * 1000
)
getCandles()
