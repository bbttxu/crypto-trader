R = require 'ramda'
Postal = require 'postal'

Stream = require './stream'

river = Postal.channel 'message'

module.exports = ( currencies )->
  console.log currencies

  currencyStream = (product)->
    channel = Stream product

    channel.subscribe "message:#{product}", ( message )->
      river.publish "match", message if 'match' is message.type

  R.map currencyStream, currencies

  river
