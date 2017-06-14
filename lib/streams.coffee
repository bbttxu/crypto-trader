R = require 'ramda'
Postal = require 'postal'

Stream = require './stream.coffee'

river = Postal.channel 'message'

module.exports = ( currencies )->
  console.log currencies


  currencyStream = (product)->
    channel = Stream product

    channel.subscribe "message:#{product}", ( message )->
      river.publish "message", message




  R.map currencyStream, currencies

  river



