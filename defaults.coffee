# # defaults.coffee

# R = require 'ramda'

# config = require './config'




# module.exports = ( config, defaultValue = {} )->
#   createKeys = ( values, currency )->
#     obj = {}

#     addCurrency = ( defaults, side )->
#       key = [ currency, side ].join('-').toUpperCase()

#       obj = {}

#       # obj[key] = R.mergeAll [ config.default.trade, config.currencies[currency][side] ]
#       obj[key] = defaultValue
#       obj

#     R.mergeAll R.values R.mergeAll R.mapObjIndexed addCurrency, values


#   R.mergeAll R.values R.mapObjIndexed createKeys, config.currencies
