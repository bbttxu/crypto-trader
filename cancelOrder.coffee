

Stream = require './lib/stream'
gdax = require './lib/gdax-client'
cleanUpTrade = require './lib/cleanUpTrades'

trade =
  product_id: 'ETH-BTC'
  side: 'buy'
  size: 0.1
  price: 0.01183


order = cleanUpTrade trade



cancelSuccess = (order)->
  console.log 'cancelSuccess', order

cancelError = (order)->
  console.log 'cancelError', order


btcStream = Stream order.product_id
btcStream.subscribe 'message', (message)->
  # console.log message
  client_oid = message.client_oid

  if client_oid is order.client_oid
    console.log message.client_oid, message.order_id

    foo = ->
      gdax.cancelOrder(message.order_id).then(cancelSuccess).catch(cancelError)

    foo()

    setTimeout foo, 1000


buySuccess = (order)->
  console.log 'buySuccess'
  body = JSON.parse order.body
  console.log body


buyError = (order)->
  console.log 'buyError', order


console.log order


test = ->
  gdax.buy(order).then(buySuccess).catch(buyError)

setTimeout test, 1000




