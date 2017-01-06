R = require 'ramda'
moment = require 'moment'

gdax = require './lib/gdax-client'
saveFill = require './lib/saveFill'

config = require './config'


INTERVAL = 1000


throttledDispatchFill = (match, index = 0)->
  wereGood = (result)->

    since = moment( match.created_at ).fromNow( true )
    if result is true
      console.log '$', since
    else
      console.log '+', since

  orNot = (result)->
    console.log 'orNot', result


  sendThrottledDispatchFill = ->

    saveFill( match ).then( wereGood ).catch(orNot)

  setTimeout sendThrottledDispatchFill, ( ( index * INTERVAL ) + ( Math.random() * INTERVAL ) )


saveFills = ( fills )->
  # console.log fills
  mapIndexed = R.addIndex R.map
  mapIndexed throttledDispatchFill, R.reverse fills

cantSaveFills = ( fills )->
  console.log 'cantSaveFills', fills


getCurrencyFills = ( product_id )->
  gdax.getFills( product_id ).then( saveFills ).catch( cantSaveFills )


module.exports = ->
  R.map getCurrencyFills, R.keys config.currencies
