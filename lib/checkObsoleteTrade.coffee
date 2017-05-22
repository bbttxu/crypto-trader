checkObsoleteTrade = ( trade, price )->

  tradePrice = parseFloat( trade.price )

  newPrice = parseFloat( price )

  if trade.side is 'sell'
    if tradePrice > newPrice
      return false

  if trade.side is 'buy'
    if tradePrice < newPrice
      return false

  true

module.exports = checkObsoleteTrade
