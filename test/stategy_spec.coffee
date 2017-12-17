
# should = require 'should'

# stategy = require '../lib/stategy'

# describe 'stategy', ->
#   it 'suggest sell when all crypto against USD are up over past 24 hours', ->

#     input =
#       'BTC-USD':
#         open: '2700.98000000'
#         high: '2808.78000000'
#         low: '2611.41000000'
#         volume: '14089.26793633'
#         last: '2785.45000000'
#         volume_30day: '549927.99376405'
#       'LTC-USD':
#         open: '28.87000000'
#         high: '30.85000000'
#         low: '27.99000000'
#         volume: '303268.37611229'
#         last: '30.19000000'
#         volume_30day: '13725441.3761901'
#       'ETH-USD':
#         open: '255.73000000'
#         high: '261.00000000'
#         low: '250.00000000'
#         volume: '142351.75567783'
#         last: '257.56000000'
#         volume_30day: '7720386.72199821'
#       'ETH-BTC':
#         open: '0.09463000'
#         high: '0.09557000'
#         low: '0.09201000'
#         volume: '9236.64963507'
#         last: '0.09265000'
#         volume_30day: '862268.91980152'
#       'LTC-BTC':
#         open: '0.01064000'
#         high: '0.01127000'
#         low: '0.01042000'
#         volume: '32730.04591892'
#         last: '0.01088000'
#         volume_30day: '1885740.08020019'

#     expected =
#       # 'BTC-USD':
#       #   sell: {}

#       # 'LTC-USD':
#       #   sell: {}

#       # 'ETH-USD':
#       #   sell: {}

#       'ETH-BTC':
#         sell: {}
#         buy: {}

#       'LTC-BTC':
#         sell: {}
#         buy: {}

#     result = stategy input

#     result.should.be.eql expected

#   it 'suggest nothing when one crypto against USD is negative over past 24 hours', ->

#     input =
#       # 'BTC-USD':
#       #   open: '2700.98000000'
#       #   high: '2808.78000000'
#       #   low: '2611.41000000'
#       #   volume: '14089.26793633'
#       #   last: '2785.45000000'
#       #   volume_30day: '549927.99376405'
#       # 'LTC-USD':
#       #   open: '28.87000000'
#       #   high: '30.85000000'
#       #   low: '27.99000000'
#       #   volume: '303268.37611229'
#       #   last: '30.19000000'
#       #   volume_30day: '13725441.3761901'
#       # 'ETH-USD':
#       #   last: '255.73000000'
#       #   high: '261.00000000'
#       #   low: '250.00000000'
#       #   volume: '142351.75567783'
#       #   open: '257.56000000'
#       #   volume_30day: '7720386.72199821'
#       'ETH-BTC':
#         open: '0.09463000'
#         high: '0.09557000'
#         low: '0.09201000'
#         volume: '9236.64963507'
#         last: '0.09265000'
#         volume_30day: '862268.91980152'
#       'LTC-BTC':
#         open: '0.01064000'
#         high: '0.01127000'
#         low: '0.01042000'
#         volume: '32730.04591892'
#         last: '0.01088000'
#         volume_30day: '1885740.08020019'

#     expected =
#       # 'BTC-USD':
#       #   {}

#       # 'LTC-USD':
#       #   {}

#       # 'ETH-USD':
#       #   {}

#       'ETH-BTC':
#         sell: {}
#         buy: {}

#       'LTC-BTC':
#         sell: {}
#         buy: {}

#     result = stategy input

#     result.should.be.eql expected


#   it 'suggest buy when all crypto against USD is negative over past 24 hours', ->

#     input =
#       # 'BTC-USD':
#       #   last: '2700.98000000'
#       #   high: '2808.78000000'
#       #   low: '2611.41000000'
#       #   volume: '14089.26793633'
#       #   open: '2785.45000000'
#       #   volume_30day: '549927.99376405'
#       # 'LTC-USD':
#       #   last: '28.87000000'
#       #   high: '30.85000000'
#       #   low: '27.99000000'
#       #   volume: '303268.37611229'
#       #   open: '30.19000000'
#       #   volume_30day: '13725441.3761901'
#       # 'ETH-USD':
#       #   last: '255.73000000'
#       #   high: '261.00000000'
#       #   low: '250.00000000'
#       #   volume: '142351.75567783'
#       #   open: '257.56000000'
#       #   volume_30day: '7720386.72199821'
#       'ETH-BTC':
#         open: '0.09463000'
#         high: '0.09557000'
#         low: '0.09201000'
#         volume: '9236.64963507'
#         last: '0.09265000'
#         volume_30day: '862268.91980152'
#       'LTC-BTC':
#         open: '0.01064000'
#         high: '0.01127000'
#         low: '0.01042000'
#         volume: '32730.04591892'
#         last: '0.01088000'
#         volume_30day: '1885740.08020019'

#     expected =
#       # 'BTC-USD':
#       #   buy: {}

#       # 'LTC-USD':
#       #   buy: {}

#       # 'ETH-USD':
#       #   buy: {}

#       'ETH-BTC':
#         sell: {}
#         buy: {}

#       'LTC-BTC':
#         sell: {}
#         buy: {}

#     result = stategy input

#     result.should.be.eql expected
