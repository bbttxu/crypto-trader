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
    ,
      price: '7.95000000'
      time: '2016-12-18T18:29:50.000000Z'
    ]

    result = predictor results

    expected = {
      current: '7.95'
      linear: 7.950001466401856
      n: 5
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
    ,
      price: '7.95000000'
      time: '2016-12-18T18:29:50.000000Z'
    ]

    result = predictor results

    expected = {
      current: '7.95'
      n: 5
    }

    expected.should.be.eql result

  it 'should return empty on no fills', ->

    predictor = predictions 'buy', 1482086050, 'BTC-USD'

    result = predictor []

    expected = {
      n: 0
    }

    expected.should.be.eql result
