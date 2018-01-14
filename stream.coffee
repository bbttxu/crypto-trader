require('dotenv').config { silent: true }

Gdax = require 'gdax'

authentication =
  secret: process.env.API_SECRET
  key: process.env.API_KEY
  passphrase: process.env.API_PASSPHRASE


Redis = require 'ioredis'

exit = require './lib/exit'

{
  keys
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
  pub.publish message.product_id, JSON.stringify message
