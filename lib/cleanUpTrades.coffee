pricing = require './pricing'

cleanUpTrades = ( trade )->
  priceFormat = trade.product_id.split( '-' )[1]

  if 'USD' is priceFormat
    trade.price = pricing.usd trade.price, trade.side

  if 'BTC' is priceFormat
    trade.price = pricing.btc trade.price, trade.side

  trade.size = pricing.btc trade.size
  trade

module.exports = cleanUpTrades
