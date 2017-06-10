{
  keys
  filter
  pick
  values
  all
  map
  merge
  equals
} = require 'ramda'

# determine if a product trades against USD
tradesAgainstUSD = ( product )->
  parts = product.split '-'
  parts[1] is 'USD'

# determine if latest price is greater than open
lastIsHigherThanOpen = ( stats )->
  parseFloat( stats.last ) > parseFloat( stats.open )

#
# possible resultant states
buyAdvice =
  buy: {}

sellAdvice =
  sell: {}

module.exports = ( stats )->

  # get USD products
  usdProducts = filter tradesAgainstUSD, keys stats

  # get USD product stats
  usdStats = pick usdProducts, stats

  # are all stats positive
  shouldWeSell = all equals(true), values map lastIsHigherThanOpen, usdStats
  # TODO why doesn't the line below work?
  # shouldWeSell = all lastIsHigherThanOpen, usdStats


  # determine advice
  asdf = if ( true is shouldWeSell ) then sellAdvice else buyAdvice

  makeProductAdvice = ->
    asdf

  # apply advice
  currentAdvice = map makeProductAdvice, usdStats


  #
  # TODO this _should_ reflect the initial config pattern
  gee =
    'BTC-USD':
      sell: {}
      buy: {}

    'LTC-USD':
      sell: {}
      buy: {}

    'ETH-USD':
      sell: {}
      buy: {}

    'ETH-BTC':
      sell: {}
      buy: {}

    'LTC-BTC':
      sell: {}
      buy: {}


  merge gee, currentAdvice
