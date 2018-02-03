should = require 'should'

averageOf = require '../lib/averageOf'

describe 'average of', ->
  it 'should average array of objects', ->

    input = [
      a: 1
      b: 2
    ,
      a: 3
      b: 4
    ,
      a: 5
      b: 6
    ,
      a: 8
      b: 9
    ]

    ( averageOf( 'a' )( input ) ).should.be.eql 4.25
    ( averageOf( 'b' )( input ) ).should.be.eql 5.25
