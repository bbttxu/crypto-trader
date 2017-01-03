R = require 'ramda'

halfsies = require './halfsies'
cleanUpTrades = require './cleanUpTrades'

module.exports = ( currencies, predictions )->

  proposeTrade = ( doc )->
    amount = halfsies doc.current, doc.linear, currencies.currencies[doc.top].balance

    obj =
      price: doc.linear
      size: amount
      side: doc.side
      product_id: [ doc.top, doc.bottom ].join '-'



  predictionSides = ( value, key )->
    parts = key.split( '-' )

    value.side = parts[2].toLowerCase()
    value.top = parts[0]
    value.bottom = parts[1]
    value.product = [ parts[0], parts[1]].join '-'
    value

  notActionable = ( doc )->
    doc.linear is undefined

  bySide = ( doc )->
    return doc.side

  sided = R.groupBy bySide, R.reject notActionable, R.values R.mapObjIndexed predictionSides, R.mergeAll predictions

  # console.log 'sided', sided

  notTradeable = ( doc )->
    doc.size < 0.01


  orders = R.map cleanUpTrades, R.reject notTradeable, R.map proposeTrade, R.flatten R.values sided

  # console.log 'orders', orders
  orders
