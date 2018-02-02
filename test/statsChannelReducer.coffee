should = require 'should'

statsChannelReducer = require '../reducers/statsChannelReducer'

describe 'stats channel reducer', ->
  it 'initial state', ->

    decision = statsChannelReducer undefined
    decision.should.be.eql {}

  it 'do NOT buy if last is higher than open', ->
    state =
      a:
        foo: 'bar'

    action =
      type: 'UPDATE'
      product_id: 'b'
      stats:
        baz: 1

    expected =
      a:
        foo: 'bar'
      b:
        baz: 1


    decision = statsChannelReducer state, action
    decision.should.be.eql expected





