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
  if 0 is fills.length
    return "Zero Fills"

  base = fills[0].product_id.split( '-' )[1]

  details = annotate map sum, map getPrices, groupBy prop( 'side' ), fills
  "#{details.balance}#{base}; sell: #{parseInt(details.sell)}, buy: #{parseInt(details.buy)}"



module.exports = showStatus
