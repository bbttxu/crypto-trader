should = require 'should'

quantize = require '../lib/quantize'

describe 'quantize', ->
  it 'quantizer 10', ->
    quantizer = quantize 10

    quantizer( .075 ).should.be.eql 0.1
    quantizer( .025 ).should.be.eql 0.0
    quantizer( .975 ).should.be.eql 1.0
    quantizer( .925 ).should.be.eql 0.9


  it 'quantizer 100', ->
    quantizer = quantize 100

    quantizer( .075 ).should.be.eql .08
    quantizer( .025 ).should.be.eql .03
    quantizer( .975 ).should.be.eql .98
    quantizer( .925 ).should.be.eql .93


