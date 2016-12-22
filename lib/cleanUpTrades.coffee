pricing = require './pricing'

cleanUpTrades = ( trade )->
  trade.price = pricing.usd trade.price, trade.side
  trade.size = pricing.btc trade.size
  trade

module.exports = cleanUpTrades
