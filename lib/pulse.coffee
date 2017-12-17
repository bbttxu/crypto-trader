# R = require 'ramda'

# defaultThreshold =
#   volume: 0
#   price: 0

# pulse = ( threshold )->
#   ( aggregate )->
#     # console.log threshold, aggregate

#     priceSignal = aggregate.price >= threshold.price
#     if threshold.price < 0
#       priceSignal = aggregate.price <= threshold.price

#     volumeSignal = aggregate.volume >= threshold.volume

#     # true if either is
#     volumeSignal and priceSignal

# module.exports = pulse
