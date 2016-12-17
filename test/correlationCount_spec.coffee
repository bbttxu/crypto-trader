should = require 'should'

correlationCount = require '../lib/correlationCount'

testData = [
  246889711,
  246889716,
  246889721,
  246889726,
  246889731,
  246889741,
  246889746,
]

describe 'correlation count', ->
  it 'finds the frequency of spacing', ->

    expected = [
      { count: 4, spacing: 10 },
      { count: 4, spacing: 5 },
      { count: 3, spacing: 15 },
      { count: 2, spacing: 20 },
      { count: 1, spacing: 30 },
      { count: 1, spacing: 25 }
    ]

    correlationCount(testData).then (value)->
      value.should.be.eql expected
