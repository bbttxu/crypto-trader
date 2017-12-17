# productSideLenses = require '../lib/productSideLenses'

# should = require 'should'


# #
# describe 'productSideLenses', ->

#   #
#   it 'takes one array, appends another', ->
#     input =
#       currencies:
#         'BTC-USD':
#           buy: {}

#         'LTC-USD':
#           sell: {}

#         'ETH-USD':
#           buy: {}

#         'ETH-BTC':
#           sell: {}
#           buy: {}

#         'LTC-BTC':
#           sell: {}
#           buy: {}


#     expected = [
#       [
#         'BTC-USD'
#         'buy'
#       ], [
#         'LTC-USD'
#         'sell'
#       ], [
#         'ETH-USD'
#         'buy'
#       ], [
#         'ETH-BTC'
#         'sell'
#       ], [
#         'ETH-BTC'
#         'buy'
#       ], [
#         'LTC-BTC'
#         'sell'
#       ], [
#         'LTC-BTC'
#         'buy'
#       ]
#     ]

#     result = productSideLenses input

#     result.should.be.deepEqual expected
