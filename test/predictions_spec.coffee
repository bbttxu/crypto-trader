should = require 'should'

predictions = require '../lib/predictions'

describe 'predictions', ->
  it 'should calculate positive trend', ->

    predictor = predictions 'sell', 1482086050, 'BTC-USD'

    results = [
      price: '7.90000000'
      time: '2016-12-18T18:29:10.000000Z'
    ,
      price: '7.90000000'
      time: '2016-12-18T18:29:20.000000Z'
    ,
      price: '8.00000000'
      time: '2016-12-18T18:29:30.000000Z'
    ,
      price: '8.00000000'
      time: '2016-12-18T18:29:40.000000Z'
    ]

    result = predictor results

    expected = {
      current: '8.00'
      linear: 8.496875000186265
      n: 4
    }

    expected.should.be.eql result

  it 'should return nothing on negative trend', ->

    predictor = predictions 'buy', 1482086050, 'BTC-USD'

    results = [
      price: '7.90000000'
      time: '2016-12-18T18:29:10.000000Z'
    ,
      price: '7.90000000'
      time: '2016-12-18T18:29:20.000000Z'
    ,
      price: '8.00000000'
      time: '2016-12-18T18:29:30.000000Z'
    ,
      price: '8.00000000'
      time: '2016-12-18T18:29:40.000000Z'
    ]

    result = predictor results

    expected = {
      current: '8.00'
      n: 4
    }

    expected.should.be.eql result
