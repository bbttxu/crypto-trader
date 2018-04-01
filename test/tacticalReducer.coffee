should = require 'should'

tacticalReducer = require '../reducers/tactical'

describe 'tactical reducer', ->
  it 'initial state', ->

    expected =
      advice: {}
      strategic: {}
      frontline: {}
      proposals: {}
      _hash: 'undefinedtacticalhash'

    decision = tacticalReducer undefined
    decision.should.be.eql expected

