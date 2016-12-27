should = require 'should'

matchesToCartesian = require '../lib/matchesToCartesian'

describe 'matches to cartesian', ->
  it 'it uses first price occurence', ->

    testMatches = [
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

    expected = [
      [ 1482085750, 7.90 ]
      [ 1482085770, 8.00 ]
    ]

    results = matchesToCartesian testMatches

    results.should.be.eql expected


  it 'it uses first price for orders occuring in the same second', ->

    testMatches = [
      price: '8.00000000'
      time: '2016-12-18T18:29:10.000000Z'
    ,
      price: '8.10000000'
      time: '2016-12-18T18:29:20.000000Z'
    ,
      price: '7.90000000'
      time: '2016-12-18T18:29:20.000000Z'
    ,
      price: '7.90000000'
      time: '2016-12-18T18:29:40.000000Z'
    ]

    expected = [
      [ 1482085750, 8.00 ]
      [ 1482085760, 8.10 ]
      [ 1482085780, 7.90 ]
    ]

    results = matchesToCartesian testMatches

    results.should.be.eql expected



  it 'it uses last price occurence', ->

    testMatches = [
      price: '8.00000000'
      time: '2016-12-18T18:29:10.000000Z'
    ,
      price: '8.00000000'
      time: '2016-12-18T18:29:20.000000Z'
    ,
      price: '7.90000000'
      time: '2016-12-18T18:29:30.000000Z'
    ,
      price: '7.90000000'
      time: '2016-12-18T18:29:40.000000Z'
    ]

    expected = [
      [ 1482085760, 8.00 ]
      [ 1482085780, 7.90 ]
    ]

    results = matchesToCartesian testMatches, true

    results.should.be.eql expected

  it 'it uses last price for orders occuring in the same second', ->

    testMatches = [
      price: '8.00000000'
      time: '2016-12-18T18:29:10.000000Z'
    ,
      price: '8.00000000'
      time: '2016-12-18T18:29:20.000000Z'
    ,
      price: '8.10000000'
      time: '2016-12-18T18:29:20.000000Z'
    ,
      price: '7.90000000'
      time: '2016-12-18T18:29:40.000000Z'
    ]

    expected = [
      [ 1482085760, 8.10 ]
      [ 1482085780, 7.90 ]
    ]

    results = matchesToCartesian testMatches, true

    results.should.be.eql expected



