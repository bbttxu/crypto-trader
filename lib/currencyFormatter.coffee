pricing = require './pricing.coffee'

currencies =
  usd: '$'
  btc: 'Ƀ'

module.exports = (product)->
  currency = (product.split('-')[1]).toLowerCase()
  currencyValue = pricing[currency]

  (value)->
    "#{currencies[currency]}#{currencyValue(value)}"
