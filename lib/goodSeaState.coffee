{
  last
  filter
  prop
} = require 'ramda'

otherSide = require './otherSide'

goodSeaState = ( state )->
  future = parseFloat state[ state.side ].bid.price

  filterOtherSide = ( fill )->
    fill.side is otherSide state.side

  latest = prop 'price', last filter filterOtherSide, state.fills

  lossIsNegative = future - latest > 0

  if 'buy' is state.side
    return not lossIsNegative

  lossIsNegative


module.exports = goodSeaState
