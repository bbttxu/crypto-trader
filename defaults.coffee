# defaults.coffee

R = require 'ramda'

config = require './config'


createKeys = ( values, currency )->
  obj = {}

  addCurrency = ( defaults, side )->
    key = [ currency, side ].join('-').toUpperCase()

    obj = {}

    obj[key] = R.mergeAll [ config.default.trade, config.currencies[currency][side] ]

    obj

  R.mergeAll R.values R.mergeAll R.mapObjIndexed addCurrency, values


module.exports = ( config )->
  R.mergeAll R.values R.mapObjIndexed createKeys, config.currencies
