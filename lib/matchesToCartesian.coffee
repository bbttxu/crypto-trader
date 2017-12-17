# R = require 'ramda'
# moment = require 'moment'

# # convert document to cartesian using
# # x-value is unix time seconds
# # y-value is price
# docToCartesian = (doc)->
#   x = doc.timestamp
#   y = parseFloat doc.price
#   [ x, y ]


# reduceToFirstPriceOccurence = (accumulator = [], value)->
#   last = R.last accumulator

#   if last is undefined
#     last = value
#     accumulator.push last

#   if last[1] isnt value[1] and last[0] isnt value[0]
#     accumulator.push value

#   accumulator


# reduceToLastPriceOccurence = (accumulator = [], value)->
#   last = R.last accumulator

#   if last is undefined
#     last = value
#     accumulator.push last

#     return accumulator

#   if last[1] is value[1] or last[0] is value[0]
#     accumulator = R.dropLast 1, accumulator

#   accumulator.push value

#   accumulator


# matchesToCartesian = ( docs, countAtEnd = false )->
#   mappedDocs = R.map docToCartesian, docs

#   if countAtEnd is false
#     return R.reduce reduceToFirstPriceOccurence, [], mappedDocs

#   else
#     return R.reduce reduceToLastPriceOccurence, [], mappedDocs


# module.exports = matchesToCartesian
