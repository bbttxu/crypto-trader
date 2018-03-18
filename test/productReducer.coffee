should = require 'should'

productReducer = require '../reducers/product'

describe '', ->
  it 'returns initial state on unknown state', ->
    reducer = productReducer 'LTC-USD'

    input = undefined

    output = reducer input

    expected =
      tick: 0
      runs: []
      bids: []

    output.should.be.eql expected

  it 'returns passed state on unknown action', ->
    reducer = productReducer 'LTC-USD'

    state =
      hello: 'world'
      unknown: 'state'

    output = reducer state

    output.should.be.eql state



  it 'returns passed state on unknown action', ->
    reducer = productReducer 'LTC-USD'

    state =
      bids: [
        id: 'asdf'
      ,
        id: 'ghjk'
      ]
      tick: 53

    input =
      type: 'ADD_BID_FROM_STORAGE'
      product: 'LTC-USD'
      bid:
        id: 'qwert'

    output = reducer state, input

    expected =
      bids: [
        id: 'asdf'
      ,
        id: 'ghjk'
      ,
        id: 'qwert'
      ]
      tick: 54
      bid_ids: [ 'asdf', 'ghjk' ]
      bids_hash: '1ecb8798d989c02528482bb3777e93cb'

    output.should.be.eql expected
