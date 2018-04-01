should = require 'should'

tacticalReducer = require '../reducers/tactical'

describe 'tactical reducer', ->
  it 'initial state', ->

    expected = {}

    decision = tacticalReducer undefined
    decision.should.be.eql expected

