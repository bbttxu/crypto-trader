# pricing.coffee

USD_PLACES = 2
BTC_PLACES = 8

fix = (places, value, side )->
  power = Math.pow( 10, places )

  # console.log places, value, side, power

  rootValue = value * power

  roundedPower = Math.round( rootValue ) / power

  # console.log 'rootValue', rootValue

  if ( 'sell' is side )
    roundedPower = Math.ceil( rootValue ) / power
    # console.log 'side sell', roundedPower

  if ( 'buy' is side )
    roundedPower = Math.floor( rootValue ) / power
    # console.log 'side buy', roundedPower

  # console.log roundedPower

  roundedPower.toFixed places


usd = (usd, side)->
  fix USD_PLACES, usd, side

btc = (btc, side)->
  fix BTC_PLACES, btc, side

module.exports =
  usd: usd
  btc: btc
