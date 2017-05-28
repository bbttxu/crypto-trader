state =
  currencies:
    LTC:
      hold: '0.0300000000000000'
      balance: '4.6900000000000000'
    BTC:
      hold: '0.0074351387000000'
      balance: '0.6395626267275402'
    USD:
      hold: '76.1685457500000000'
      balance: '79.6591886046004000'
    ETH:
      hold: '0.0300000000000000'
      balance: '4.9827126900000000'
  prices:
    'LTC-USD-BUY':
      time: '2017-05-27T13:20:49.644000Z'
      price: '22.59000000'
    'LTC-BTC-BUY':
      time: '2017-05-27T04:50:09.682000Z'
      price: '0.01088000'
    'BTC-USD-BUY':
      time: '2017-05-27T13:20:50.226000Z'
      price: '2035.33000000'
    'BTC-USD-SELL':
      time: '2017-05-27T13:20:54.378000Z'
      price: '2036.84000000'
    'ETH-BTC-BUY':
      time: '2017-05-27T06:46:57.710000Z'
      price: '0.06974000'
    'ETH-BTC-SELL':
      time: '2017-05-27T10:07:35.914000Z'
      price: '0.06419000'
    'LTC-BTC-SELL':
      time: '2017-05-27T06:45:16.210000Z'
      price: '0.01091000'
    'LTC-USD-SELL':
      time: '2017-05-27T03:16:03.035000Z'
      price: '25.27000000'
    'ETH-USD-SELL':
      time: '2017-05-27T13:20:55.932000Z'
      price: '150.69000000'

should = require 'should'

determinePosition = require '../lib/positionDetermine'

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

    expected =
      LTC:
        hold: '0.0300000000000000'
        balance: '4.6900000000000000'
        holdUSD: '0.76'
        balanceUSD: '118.52'
      BTC:
        hold: '0.0074351387000000'
        balance: '0.6395626267275402'
        holdUSD: '15.14'
        balanceUSD: '1302.69'
      USD:
        hold: '76.1685457500000000'
        balance: '79.6591886046004000'
        holdUSD: '76.17'
        balanceUSD: '79.66'
      ETH:
        hold: '0.0300000000000000'
        balance: '4.9827126900000000'
        holdUSD: '4.52'
        balanceUSD: '750.84'
      total:
        holdUSD: 96.59
        balanceUSD: 2251.71
        totalUSD: 2348.3

    results = determinePosition state.currencies, state.prices

    results.should.be.eql expected
