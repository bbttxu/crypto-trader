otherSide = ( side )->
  if 'sell' is side
    return 'buy'

  if 'buy' is side
    return 'sell'

  return


module.exports = otherSide
