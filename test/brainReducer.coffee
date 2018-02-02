should = require 'should'

brainReducer = require '../reducers/brainReducer'

describe 'stats channel reducer', ->
  it 'initial state', ->

    expected =
      stats: {}
      directions: {}

    decision = brainReducer undefined
    decision.should.be.eql expected

  it 'do NOT buy if last is higher than open', ->
    state =
      stats:
        'ABC-GHI':
          last: 2
          open: 1

    action =
      type: 'UPDATE'
      stats:
        'ABC-GHI':
          last: 3
          open: 1

    expected =
      'ABC-GHI': 'sell'


    decision = brainReducer state, action
    decision.directions.should.be.eql expected



  it 'allows sell when matched', ->
    state =
      stats:
        'ABC-GHI':
          last: 2
          open: 1

    action =
      type: 'UPDATE'
      stats:
        'ABC-GHI':
          last: 3
          open: 1


    brainReducer state, action

    action2 =
      type: 'UPDATE'
      stats:
        'DEF-GHI':
          last: 3
          open: 1


    expected =
      'ABC-GHI': 'sell'
      'DEF-GHI': 'sell'


    decision = brainReducer state, action2
    decision.directions.should.be.eql expected



  it 'advises hold on split', ->
    state =
      stats:
        'ABC-GHI':
          last: 2
          open: 1

    action =
      type: 'UPDATE'
      stats:
        'ABC-GHI':
          last: 3
          open: 1


    brainReducer state, action

    action2 =
      type: 'UPDATE'
      stats:
        'DEF-GHI':
          last: 1
          open: 3


    expected =
      'ABC-GHI': 'hold'
      'DEF-GHI': 'hold'


    decision = brainReducer state, action2
    decision.directions.should.be.eql expected



