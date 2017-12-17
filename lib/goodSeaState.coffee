# {
#   last
#   filter
#   prop
#   isEmpty
# } = require 'ramda'

# otherSide = require './otherSide'

# goodSeaState = ( state )->

#   # return if there are no fills shown
#   return false if isEmpty state.fills

#   filterOtherSide = ( fill )->
#     fill.side is otherSide state.match.side

#   theOtherSide = filter filterOtherSide, state.fills

#   return false if isEmpty theOtherSide

#   future = parseFloat state[ state.match.side ].bid.price

#   latest = prop 'price', last theOtherSide

#   lossIsNegative = ( future - latest ) > 0

#   if 'buy' is state.match.side
#     return not lossIsNegative

#   lossIsNegative


# module.exports = goodSeaState
