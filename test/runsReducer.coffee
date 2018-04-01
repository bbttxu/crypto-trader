should = require 'should'

runsReducer = require '../reducers/runs'

describe 'runs channel reducer', ->
  it 'initial state', ->

    expected = {
      run: []
      runs: []
      stats: {}
      currencyStats: {}
    }

    decision = runsReducer undefined
    decision.should.be.eql expected

#   it 'do NOT buy if last is higher than open', ->
#     state =
#       'ABC-GHI':
#         buy: 1

#     action =
#       type: 'UPDATE_PRICING'
#       match:
#         product_id: 'ABC-GHI'
#         side: 'sell'
#         size: 1
#         price: 89.3

#         # 'ABC-GHI':
#         #   last: 3
#         #   open: 1

#     expected =
#       'ABC-GHI':
#         buy: 1
#         sell: 89.3

#     decision = runsReducer state, action
#     decision.should.be.eql expected


