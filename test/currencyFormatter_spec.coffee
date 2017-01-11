should = require 'should'

currencyFormatter = require '../lib/currencyFormatter'

describe 'currency formatter', ->
  it 'formats usd', ->
    usdFormatter = currencyFormatter 'BTC-USD'
    result = usdFormatter 10.234
    expected = '$10.23'
    result.should.be.eql expected

  it 'formats btc', ->
    btcFormatter = currencyFormatter 'ETH-BTC'
    result = btcFormatter 10.2345678
    expected = 'Ƀ10.23457'
    result.should.be.eql expected


