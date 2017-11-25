{
  last
  filter
  prop
  isEmpty
} = require 'ramda'

otherSide = require './otherSide'

goodSeaState = ( state )->

  # return if there are no fills shown
  return false if isEmpty state.fills

  future = parseFloat state[ state.match.side ].bid.price

  filterOtherSide = ( fill )->
    fill.side is otherSide state.match.side

  latest = prop 'price', last filter filterOtherSide, state.fills

  lossIsNegative = ( future - latest ) > 0

  if 'buy' is state.match.side
    return not lossIsNegative

  lossIsNegative


module.exports = goodSeaState
