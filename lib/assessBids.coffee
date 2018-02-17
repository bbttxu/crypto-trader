{
  groupBy
  map
  prop
  pick
  filter
  sum
} = require 'ramda'

groupBySide = groupBy prop 'side'

getValue = ( bid )->
  ( parseFloat bid.price ) * ( parseFloat bid.size )

getSideSum = map ( side )->
  prices = map prop( 'price' ), side

  sideSum =
    sum: sum map getValue, side
    size: sum map parseFloat, map prop( 'size' ), side


  sideSum.n = side.length
  sideSum.price =
    min: Math.min.apply this, prices
    avg: sideSum.sum / sideSum.size
    max: Math.max.apply this, prices

  sideSum

assessBids = ( bids )->
  getSideSum groupBySide map(
    pick ['id', 'side', 'size', 'price', 'created_at']

    filter(
      ( bid )->
        'filled' is bid.reason
      ,
      bids
    )
  )

module.exports = assessBids
