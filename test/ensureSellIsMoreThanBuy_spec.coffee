should = require 'should'

ensureSellIsMoreThanBuy = require '../lib/ensureSellIsMoreThanBuy'

describe 'ensureSellIsMoreThanBuy', ->
  it 'should not change things if they are good', ->
    input = {
      sell: 52
      buy: 51
    }

    expected = {
      sell: 52
      buy: 51
    }


    output = ensureSellIsMoreThanBuy input, 'sell'

    expected.should.be.eql output


  it 'should make the sell price larger than buy', ->
    input = {
      sell: 51
      buy: 52
    }

    expected = {
      sell: 52
      buy: 51
    }


    output = ensureSellIsMoreThanBuy input, 'sell'

    expected.should.be.eql output
