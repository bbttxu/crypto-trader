{
  set
  view
  lensProp
  reject
  isNil
} = require 'ramda'


ensureSellIsMoreThanBuy = ( data )->

  sellLens = lensProp 'sell'
  buyLens = lensProp 'buy'

  sell = view sellLens, data
  buy = view buyLens, data

  prices = reject isNil, [ buy, sell ]

  if 2 is prices.length
    data = set sellLens, Math.max.apply( this, prices ), data
    data = set buyLens, Math.min.apply( this, prices ), data

  data


module.exports = ensureSellIsMoreThanBuy
