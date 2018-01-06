{
  get
} = require 'axios'

{
  map
  countBy
  identity
  reject
  sum
  values
  clamp
} = require 'ramda'

moment = require 'moment'

# https://docs.gdax.com/#get-historic-rates
tooOld = ( candle )->
  candle[0] < moment().subtract( 1, 'day' ).unix()

# https://docs.gdax.com/#get-historic-rates
latestIsGreaterThanOpen = ( candle )->
  return 'up' if candle[3] < candle[4]
  return 'down' if candle[3] > candle[4]
  return 'even'

clamper = ( value )->
  partial = parseFloat( clamp( 0, value, 1 ).toFixed( 2 ) )
  ( partial * partial ).toFixed 3

# https://docs.gdax.com/#get-historic-rates
getRates = ->
  get(
    'https://api.gdax.com/products/ETH-USD/candles?granularity=60'
  ).then(
    ( result )->
      counts = countBy identity, map latestIsGreaterThanOpen, reject tooOld, result.data



      counts.n = sum values counts


      counts.sell = ( counts.true / counts.n )
      counts.buy = ( counts.false / counts.n )

      counts.sellFactor = clamper( counts.true / counts.false )

      counts.buyFactor = clamper( counts.false / counts.true )

      console.log counts

  )

setInterval(
  getRates,
  60 * 1000
)
getRates()
