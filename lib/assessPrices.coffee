

assessPrices = ( sides )->

  if sides.buy and sides.sell

    if sides.buy.price.avg > sides.sell.price.avg

      averageBuyPrice = sides.buy.price.avg
      sides.buy.price.avg = sides.sell.price.avg
      sides.sell.price.avg = averageBuyPrice

  return
    sell: sides.sell.price.avg
    buy: sides.buy.price.avg


module.exports = assessPrices
