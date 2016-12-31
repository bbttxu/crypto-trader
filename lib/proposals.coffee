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
    value

  notActionable = ( doc )->
    doc.linear is undefined

  bySide = ( doc )->
    return doc.side

  sided = R.groupBy bySide, R.reject notActionable, R.values R.mapObjIndexed predictionSides, R.mergeAll predictions

  notTradeable = ( doc )->
    doc.size < 0.01


  R.map cleanUpTrades, R.reject notTradeable, R.map proposeTrade, R.flatten R.values sided
