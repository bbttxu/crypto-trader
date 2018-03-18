should = require 'should'

pricingReducer = require '../reducers/pricing'

describe 'pricing channel reducer', ->
  it 'initial state', ->

    expected = {}

    decision = pricingReducer undefined
    decision.should.be.eql expected

  it 'do NOT buy if last is higher than open', ->
    state =
      prices:
        'ABC-GHI':
          buy: 1

    action =
      type: 'UPDATE_PRICING'
      match:
        product_id: 'ABC-GHI'
        side: 'sell'
        price: 89.3

    expected =
      'ABC-GHI':
        buy: 1
        sell: 89.3

    decision = pricingReducer state, action
    decision.prices.should.be.eql expected





