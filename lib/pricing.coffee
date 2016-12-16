# pricing.coffee

USD_PLACES = 2
BTC_PLACES = 8

fix = (places, value)->
  ( parseFloat value ).toFixed places

usd = (usd)->
  fix USD_PLACES, usd

btc = (btc, places = BTC_PLACES)->
  fix places, btc

module.exports =
  usd: usd
  btc: btc
