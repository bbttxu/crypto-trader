R = require 'ramda'

halfsies = ( current, projected, amount )->
  currentValue = parseFloat( current ) * parseFloat( amount )
  newAmount = currentValue / parseFloat( projected )
  Math.abs( amount - newAmount ) / 2.0

module.exports = halfsies
