
normalize = require './normalize'

{
  pick
  init
  tail
  compose
} = require 'ramda'

normalizedPrices = ( stats )->

  compose(
    # tail
    # init
    # normalize
    # values
    pick( [ 'high', 'last', 'open', 'low' ] )
  )( stats )




  #   pick( [ 'high', 'last', 'open', 'low' ] )
  # ).then(
  #   values
  # ).then(
  #   normalize
  # ).then(
  #   init
  # ).then(
  #   tail
  # )

module.exports = normalizedPrices
