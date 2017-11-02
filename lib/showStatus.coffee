{
  groupBy
  prop
  map
  sum
  values
  multiply
  pluck
} = require 'ramda'


getPrice = ( fill )->
  price = multiply(
    parseFloat(
      prop( 'size' )( fill )
    ),
    parseFloat(
      prop( 'price' )( fill )
    )
  )

  if fill.side is 'buy'
    price = multiply -1, price

  price


getPrices = ( side )->
  map getPrice, values side


showStatus = ( fills )->
  map sum, map getPrices, groupBy prop( 'side' ), fills

module.exports = showStatus
