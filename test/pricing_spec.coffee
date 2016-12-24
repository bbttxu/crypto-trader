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

  it 'formats usd properly, for a sell', ->
    value = 123.3456
    formatted = pricing.usd value, 'sell'
    formatted.should.be.eql '123.35'

  it 'formats usd properly, for a buy', ->
    value = 123.456
    formatted = pricing.usd value, 'buy'
    formatted.should.be.eql '123.45'


describe 'btc', ->
  it 'formats btc properly', ->
    value = 123.45678901234
    formatted = pricing.btc value
    formatted.should.be.eql '123.4568'

