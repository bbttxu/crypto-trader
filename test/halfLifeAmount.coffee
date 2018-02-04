halfLifeAmount = require '../lib/halfLifeAmount'

should = require 'should'


describe 'half life amount', ->
  it 'determines remaining amount', ->
    amount = halfLifeAmount 1, 100, 300
    amount.should.be.eql .125



