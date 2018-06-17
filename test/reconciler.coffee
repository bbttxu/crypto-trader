should = require 'should'

reconciler = require '../lib/reconciler'

describe 'reconciler', ->
  it 'does not reconcile a loss', ->

    buy =
      price: '0.11177000',
      size: '0.20000000',
      side: 'buy'


    sell =
      price: '0.11077000',
      size: '0.20000000',
      side: 'sell'


    reconciler( buy, sell ).should.be.eql [
      price: '0.11177000',
      size: '0.20000000',
      side: 'buy'
    ,
      price: '0.11077000',
      size: '0.20000000',
      side: 'sell'
    ,
      '0.00000000'
    ]



  it 'reconciler a gain of even size, size balance 0', ->

    buy =
      price: '0.11077000',
      size: '0.20000000',
      side: 'buy'


    sell =
      price: '0.11177000',
      size: '0.20000000',
      side: 'sell'


    reconciler( buy, sell ).should.be.eql [
      price: '0.11077000',
      size: '0.00000000',
      side: 'buy'
    ,
      price: '0.11177000',
      size: '0.00000000',
      side: 'sell'
    ,
      '0.00020000'

    ]



  it 'reconcile a gain on a larger sell size, zero buy, remainder on sell', ->

    buy =
      price: '0.11077000',
      size: '0.10000000',
      side: 'buy'


    sell =
      price: '0.11177000',
      size: '0.20000000',
      side: 'sell'


    reconciler( buy, sell ).should.be.eql [
      price: '0.11077000',
      size: '0.00000000',
      side: 'buy'
    ,
      price: '0.11177000',
      size: '0.10000000',
      side: 'sell'
    ,
      '0.00010000'
    ]


  it 'reconcile a gain on a smaller sell size, zero sell, remainder on buy', ->

    buy =
      price: '0.11077000',
      size: '0.20000000',
      side: 'buy'


    sell =
      price: '0.11177000',
      size: '0.10000000',
      side: 'sell'


    reconciler( buy, sell ).should.be.eql [
      price: '0.11077000',
      size: '0.10000000',
      side: 'buy'
    ,
      price: '0.11177000',
      size: '0.00000000',
      side: 'sell'
    ,
      '0.00010000'
    ]
