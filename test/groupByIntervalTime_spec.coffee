should = require 'should'

groupByIntervalTime = require '../lib/groupByIntervalTime'

testData = [
  time: "2016-12-17T15:57:01.082000Z"
,
  time: "2016-12-18T15:58:59.082000Z"
,
  time: "2016-12-18T15:59:01.082000Z"
]

describe 'returns intervals', ->
  it 'six seconds', ->
    groupBySixSeconds = groupByIntervalTime 6
    results = groupBySixSeconds testData

    resultArray =
      246998371: [
        time: "2016-12-17T15:57:01.082000Z"
      ]
      247012790: [
        time: "2016-12-18T15:58:59.082000Z"
      ]
      247012791: [
        time: "2016-12-18T15:59:01.082000Z"
      ]

    results.should.be.eql resultArray

  it 'one hour', ->
    groupByOneHour = groupByIntervalTime 60 * 60
    results = groupByOneHour testData

    resultArray =
      411664: [
        time: "2016-12-17T15:57:01.082000Z"
      ]
      411688: [
        time: "2016-12-18T15:58:59.082000Z"
      ,
        time: "2016-12-18T15:59:01.082000Z"
      ]

    results.should.be.eql resultArray
