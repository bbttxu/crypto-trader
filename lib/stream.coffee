# require('dotenv').config { silent: true }

# Postal = require 'postal'

# Gdax = require 'gdax'

# restart = require './restartProcess'

# authentication =
#   secret: process.env.API_SECRET
#   key: process.env.API_KEY
#   passphrase: process.env.API_PASSPHRASE

# module.exports = (product = 'BTC-USD')->

#   # pub/sub channel for long-term communication
#   channel = Postal.channel 'websocket'

#   # Init a websocket to receive data for a particular product
#   start = ->
#     websocket = new (Gdax.WebsocketClient)(product, null, authentication)

#     websocket.on 'open', ->
#       console.log "OPENED #{product} WEBSOCKET!!!"

#     websocket.on 'close', ->
#       console.log "CLOSED #{product} WEBSOCKET!!!"

#       # if socket dies, restart after a short period of time
#       setTimeout start, 10000

#     websocket.on 'message', (message)->
#       # publish message to the channel
#       # console.log message
#       channel.publish "message:#{product}", message

#   # start the websocket
#   start()

#   # return the pub/sub channel
#   channel
