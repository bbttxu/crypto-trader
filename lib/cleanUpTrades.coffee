uuid = require 'uuid'
# moment = require 'moment'

pricing = require './pricing'

cleanUpTrades = ( trade )->
  priceFormat = trade.product_id.split( '-' )[1]

  if 'USD' is priceFormat
    trade.price = pricing.usd trade.price, trade.side

  if 'BTC' is priceFormat
    trade.price = pricing.btc trade.price, trade.side

  unless trade.client_oid
    trade.client_oid = uuid.v4()

  trade.size = pricing.size trade.size
  # trade.created = moment().format()
  trade

module.exports = cleanUpTrades
