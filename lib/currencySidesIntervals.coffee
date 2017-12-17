# {
#   map
#   mergeAll
#   unnest
# } = require 'ramda'


# currencySides = require './currencySides'


# currencySidesIntervals = ( currencySides, intervals ) ->

#   mapIntervals = ( interval ) ->


#     mapCurrencySide = ( side ) ->
#       side.concat interval



#     obj = {}
#     obj[interval] = map mapCurrencySide, currencySides
#     obj



#   mergeAll map mapIntervals, intervals

#   # console.log intervals


# module.exports = currencySidesIntervals
