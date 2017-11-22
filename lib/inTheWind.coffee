moment = require 'moment'

{
  countBy
  identity
  map
  reject
  clamp
} = require 'ramda'


# https://docs.gdax.com/#get-historic-rates
tooOld = ( candle )->
  candle[0] < moment().subtract( 1, 'day' ).unix()

# https://docs.gdax.com/#get-historic-rates
latestIsGreaterThanOpen = ( candle )->
  candle[3] < candle[4]

clamper = ( value )->
  partial = parseFloat( clamp( 0, value, 1 ).toFixed( 3 ) )
  parseFloat( partial * partial ).toFixed 3

inTheWind = ( result )->
  counts = countBy(
    identity,
    map(
      latestIsGreaterThanOpen,
      reject(
        tooOld,
        result.data
      )
    )
  )

  counts.sellFactor = clamper( counts.true / counts.false )

  counts.buyFactor = clamper( counts.false / counts.true )

  return
    sellFactor: clamper( counts.true / counts.false )
    buyFactor: clamper( counts.false / counts.true )


module.exports = inTheWind


