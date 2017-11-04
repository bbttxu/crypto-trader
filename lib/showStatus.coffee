approximate = require 'approximate-number'

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

annotate = ( details )->
  details.balance = approximate details.buy + details.sell, prefix: '$', capital: true, round: true

  details

showStatus = ( fills )->
  details = annotate map sum, map getPrices, groupBy prop( 'side' ), fills
  "#{details.balance}; sell: $#{parseInt(details.sell)}, buy: $#{parseInt(details.buy)}"



module.exports = showStatus
