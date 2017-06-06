{
  max
} = require 'ramda'

###
TODO REFACTOR
currently we could return zero if we hold zero crypto
this returns an amount that should statistically
lead to a trade every 10 tries

there needs to be a better way to do this
###
MINIMUM_AMOUNT = 0.001

halfsies = ( current, projected, amount )->
  currentValue = parseFloat( current ) * parseFloat( amount )
  newAmount = currentValue / parseFloat( projected )
  max MINIMUM_AMOUNT, Math.abs( amount - newAmount ) / 2.0

module.exports = halfsies
