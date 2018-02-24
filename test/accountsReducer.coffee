should = require 'should'

accountsReducer = require '../reducers/accounts'

describe 'pricing channel reducer', ->
  it 'initial state', ->

    expected = {}

    decision = accountsReducer undefined
    decision.should.be.eql expected

