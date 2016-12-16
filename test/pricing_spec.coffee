should = require 'should'

pricing = require '../lib/pricing'

describe 'usd', ->
  it 'formats usd properly, round down', ->
    value = 123.454
    formatted = pricing.usd value
    formatted.should.be.eql '123.45'

  it 'formats usd properly, round up', ->
    value = 123.456
    formatted = pricing.usd value
    formatted.should.be.eql '123.46'

describe 'btc', ->
  it 'formats btc properly', ->
    value = 123.45678901234
    formatted = pricing.btc value
    formatted.should.be.eql '123.45678901'

