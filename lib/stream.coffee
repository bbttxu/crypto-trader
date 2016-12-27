CoinbaseExchange = require('coinbase-exchange')

module.exports = (product = 'BTC-USD')->
  # console.log product
  new CoinbaseExchange.WebsocketClient product
