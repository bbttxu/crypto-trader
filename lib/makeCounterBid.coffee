{
  sortBy
  filter
  propEq
  sum
  pluck
  pick
  equals
} = require 'ramda'

coveredBids = require './coveredBids'

coveredPrice = require './coveredPrice'

cleanUpTrade = require './cleanUpTrade'

otherSide = require './otherSide'

log = require './log'



sortByCreatedAt = sortBy prop( 'time' )

onlyFilledReasons = filter propEq( 'reason', 'filled' )



makeCounterBid = ( bids, side )->

  lastStreak = coveredBids( sortByCreatedAt( onlyFilledReasons( bids ) ), side )

  unless isEmpty lastStreak
    if lastStreak.length > 1

      price = coveredPrice lastStreak

      if price
        counterBid = cleanUpTrade
          price: price
          size: sum pluck 'size', lastStreak
          side: otherSide side
          product_id: PRODUCT_ID

        importantValues = pick [ 'price', 'size', 'side', 'product_id' ]

        log lastStreak.length, counterBid

        counterBids = filter propEq( 'reason', 'counter' ), bids

        unless equals importantValues( state.counterBid ), importantValues( counterBid )
          makeNewBid counterBid, pluck( 'id', counterBids ), 'counter'
          state.counterBid = counterBid



module.exports = makeCounterBid
