require('dotenv').config { silent: true }

Gdax = require('gdax')

restart = require './restartProcess'

authentication =
  secret: process.env.API_SECRET
  key: process.env.API_KEY
  passphrase: process.env.API_PASSPHRASE

module.exports = (product = 'BTC-USD')->
  websocket = new (Gdax.WebsocketClient)(product, null, authentication)

  websocket.on 'close', ->
    console.log "CLOSE #{product} WEBSOCKET!!!"

    # Just punt at this point, start from scratch
    # Modulus/Xervio will restart process
    restart(42)

  websocket
