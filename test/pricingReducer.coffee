should = require 'should'

pricingReducer = require '../reducers/pricing'

describe 'pricing channel reducer', ->
  it 'initial state', ->

    expected = {}

    decision = pricingReducer undefined
    decision.should.be.eql expected

  it 'do NOT buy if last is higher than open', ->
    state =
      'ABC-GHI':
        buy: 1

    action =
      type: 'UPDATE_PRICING'
      match:
        product_id: 'ABC-GHI'
        side: 'sell'
        size: 1
        price: 89.3

        # 'ABC-GHI':
        #   last: 3
        #   open: 1

    expected =
      'ABC-GHI':
        buy: 1
        sell: 89.3

    decision = pricingReducer state, action
    decision.should.be.eql expected



  # it 'allows sell when matched', ->
  #   state =
  #     stats:
  #       'ABC-GHI':
  #         last: 2
  #         open: 1

  #   action =
  #     type: 'UPDATE'
  #     stats:
  #       'ABC-GHI':
  #         last: 3
  #         open: 1


  #   pricingReducer state, action

  #   action2 =
  #     type: 'UPDATE'
  #     stats:
  #       'DEF-GHI':
  #         last: 3
  #         open: 1


  #   expected =
  #     'ABC-GHI': 'sell'
  #     'DEF-GHI': 'sell'


  #   decision = pricingReducer state, action2
  #   decision.directions.should.be.eql expected



  # it 'advises hold on split', ->
  #   state =
  #     stats:
  #       'ABC-GHI':
  #         last: 2
  #         open: 1

  #   action =
  #     type: 'UPDATE'
  #     stats:
  #       'ABC-GHI':
  #         last: 3
  #         open: 1


  #   pricingReducer state, action

  #   action2 =
  #     type: 'UPDATE'
  #     stats:
  #       'DEF-GHI':
  #         last: 1
  #         open: 3


  #   expected =
  #     'ABC-GHI': 'hold'
  #     'DEF-GHI': 'hold'


  #   decision = pricingReducer state, action2
  #   decision.directions.should.be.eql expected



  # it 'does not change state on non-actionable item', ->
  #   state =
  #     stats:
  #       'ABC-GHI':
  #         last: 2
  #         open: 1

  #   action =
  #     type: 'UPDATE'
  #     stats:
  #       'DEF-GHI':
  #         last: 1
  #         open: 3


  #   pricingReducer state, action

  #   action2 =
  #     type: 'BAD_ACTION'
  #     stats:
  #       'DEF-GHI':
  #         last: 3
  #         open: 1


  #   expected =
  #     'ABC-GHI': 'hold'
  #     'DEF-GHI': 'hold'


  #   pricingReducer( state, action2 ).directions.should.be.eql expected




