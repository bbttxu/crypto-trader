# R = require 'ramda'

# gdax = require './lib/gdax-client'

# Queue = require './lib/queue'
# queue = Queue()

# R.map queue.enqueue, R.range 1, 1000

# pop = ->
#   value = queue.dequeue()

#   if Math.random() > 0.5
#     console.log value

#   else
#     queue.enqueue value

# setInterval pop, 10



# gdax.stats( [ 'ETH-BTC' ] ).then( console.log )


# regression = require 'regression'

# values = [ [0, 1], [1, 2], [3, 4], [60, null]]

# console.log regression 'linear', values

# clearOutOldOrders = ->
#   # state = store.getState()


#   cancelOrder = ( order )->
#     cancelOrderSuccess = ( response )->
#       console.log 'cancelOrderSuccess', response, order.order_id
#       store.dispatch
#         type: 'ORDER_CANCELLED'
#         order: order

#     cancelOrderFailed = ( status )->
#       # console.log 'cancelOrderFailed', status, order

#     gdax.cancelOrder( order.order_id ).then( cancelOrderSuccess ).catch( cancelOrderFailed )

#   tooOld = ( order )->
#     # console.log order.time, moment( order.time ).isBefore moment().subtract( projectionMinutes, 'minutes' )
#     moment( order.time ).isBefore moment().subtract( projectionMinutes, config.default.interval.units )

#   expired = R.filter tooOld, state.orders
#   if expired.length > 0
#     console.log 'cancel', R.pluck 'order_id', expired
#     R.map cancelOrder, expired


# setInterval clearOutOldOrders, 1000


# foo = ->
#   console.log 'exit'
#   process.exit 1


# setInterval foo, 1000


# ASSUMPTIONS
#
# We remove runs that last less than a second because we can't trade that fast
# The minumum trade window should be an hour until we know better

matches = []

interestingBits = [
  'time'
  'side'
  'product_id'
  'size'
  'price'
]

R = require 'ramda'

moment = require 'moment'

config = require './config'

currencies = R.keys config.currencies

Streams = require './lib/streams'

streams = Streams currencies

isSameSide = (match1, match2)->
  match1.side is match2.side

onlyOne = (array)->
  array.length is 1

calculateDuration = (array)->
  first = R.head array
  last = R.last array

  earliest = moment( first.time ).valueOf()
  latest = moment( last.time ).valueOf()

  sideDuration =
    side: first.side
    duration: ( latest - earliest )
    n: array.length

bySide = (match)->
  match.side

sideStats = (values, key)->
  durations = R.pluck 'duration', values

  stats =
    n: values.length
    min: Math.min.apply this, durations
    avg: Math.round R.sum( durations ) / values.length
    max: Math.max.apply this, durations


streams.subscribe 'match', ( match )->
  console.log JSON.stringify R.pick interestingBits, match

  matches.push R.pick interestingBits, match

  asdf = R.map calculateDuration, R.groupWith isSameSide, matches

  console.log 'asdf', asdf

  grouped = R.groupBy bySide, asdf

  console.log R.mapObjIndexed sideStats, grouped

  # console.log JSON.stringify R.key





