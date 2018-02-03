should = require 'should'

statsChannelReducer = require '../reducers/statsChannelReducer'

describe 'stats channel reducer', ->
  it 'initial state', ->

    statsChannelReducer( undefined ).should.be.eql {}


  it 'does nothing for non-actionable requests', ->
    state =
      a:
        foo: 'bar'

    action =
      type: 'BAD_ACTION'
      product_id: 'b'
      stats:
        baz: 1

    expected =
      a:
        foo: 'bar'

    statsChannelReducer( state, action ).should.be.eql expected


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

    statsChannelReducer( state, action ).should.be.eql expected





