{
  last
  filter
  prop
} = require 'ramda'

otherSide = require './otherSide'

goodSeaState = ( state )->
  future = parseFloat state[ state.match.side ].bid.price

  filterOtherSide = ( fill )->
    fill.side is otherSide state.match.side

  latest = prop 'price', last filter filterOtherSide, state.fills

  lossIsNegative = future - latest > 0

  if 'buy' is state.match.side
    return not lossIsNegative

  lossIsNegative


module.exports = goodSeaState
