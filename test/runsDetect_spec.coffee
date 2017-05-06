should = require 'should'

detectRuns = require '../lib/runsDetect'


describe 'runs', ->
  it 'should detect runs', ->

    input = [
      side: 'buy'
    ,
      side: 'buy'
    ,
      side: 'sell'
    ,
      side: 'buy'
    ,
      side: 'buy'
    ,
      side: 'buy'
    ]

    expected = [
      [
          side: 'buy'
        ,
          side: 'buy'
      ]
    ,
      [
        side: 'sell'
      ]
    ,
      [
          side: 'buy'
        ,
          side: 'buy'
        ,
          side: 'buy'
      ]
    ]

    output = detectRuns input

    output.should.be.eql expected

