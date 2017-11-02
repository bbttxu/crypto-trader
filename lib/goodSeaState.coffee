{
  last
  filter
  prop
} = require 'ramda'

otherSide = require './otherSide'

goodSeaState = ( state )->
  # if state[ state.match.side ].bid
  future = parseFloat state[ state.match.side ].bid.price

  filterOtherSide = ( fill )->
    fill.side is otherSide state.match.side

  latest = prop 'price', last filter filterOtherSide, state.fills

  lossIsNegative = future - latest > 0

  if 'buy' is state.match.side
    return not lossIsNegative

  lossIsNegative

  # return false unless state[ state.match.side ].bid


module.exports = goodSeaState
