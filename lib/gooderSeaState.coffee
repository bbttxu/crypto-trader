###
.____    ._____.                      .__
|    |   |__\_ |______________ _______|__| ____   ______
|    |   |  || __ \_  __ \__  \\_  __ \  |/ __ \ /  ___/
|    |___|  || \_\ \  | \// __ \|  | \/  \  ___/ \___ \
|_______ \__||___  /__|  (____  /__|  |__|\___  >____  >
        \/       \/           \/              \/     \/
###

{
  map
  sum
  prop
  groupBy
  pick
  filter
  clamp
  isEmpty
} = require 'ramda'

moment = require 'moment'

otherSide = require './otherSide'

pricing = require './pricing'

###
___________                   __  .__
\_   _____/_ __  ____   _____/  |_|__| ____   ____   ______
 |    __)|  |  \/    \_/ ___\   __\  |/  _ \ /    \ /  ___/
 |     \ |  |  /   |  \  \___|  | |  (  <_> )   |  \\___ \
 \___  / |____/|___|  /\___  >__| |__|\____/|___|  /____  >
     \/             \/     \/                    \/     \/
###


halfLifeAmount = require './halfLifeAmount'

groupBySide = groupBy prop 'side'

deValue = map ( bid )->
  now = moment().unix()

  delta = Math.abs( now - moment( bid.created_at ).unix() )

  bid.size = halfLifeAmount bid.size, 86400, delta

  bid


getValue = ( bid )->
  ( parseFloat bid.price ) * ( parseFloat bid.size )

getSideSum = map ( side )->
  deValuedSide = deValue side

  sideSum =
    sum: sum map getValue, deValuedSide
    size: sum map parseFloat, map prop( 'size' ), deValuedSide


  sideSum.price = sideSum.sum / sideSum.size
  sideSum.n = deValuedSide.length
  sideSum


gooderSeaState = ( bids, bid )->
  # console.log JSON.stringify bid

  if isEmpty bids
    console.log 'no bids; trade away'
    return true

  unless bid
    console.log 'BAD SEA STATE', bid
    return false


  unless bid.side
    console.log 'NO BID SEA STATE', 'no bid.side', bid
    return false


  outcome = getSideSum groupBySide map(
    pick ['id', 'side', 'size', 'price', 'created_at']

    filter(
      ( bid )->
        'filled' is bid.reason
      ,
      bids
    )
  )

  unless outcome[ otherSide bid.side ]
    console.log 'no boundaries for', otherSide bid.side
    return true

  if (outcome[ otherSide bid.side ]) and (not isEmpty outcome[ otherSide bid.side ])
    if 'sell' is bid.side
      if outcome[ otherSide bid.side ].price < parseFloat bid.price
        console.log(
          [
            "+ SELL price",
            pricing.btc( parseFloat bid.price )
            "is greater than 24HR BUY"
            pricing.btc( outcome[ otherSide bid.side ].price )
          ].join ' '
        )
        return true


      console.log(
        [
          "proposed SELL price",
          pricing.btc( parseFloat bid.price )
          "is less than 24HR BUY"
          pricing.btc( outcome[ otherSide bid.side ].price )
        ].join ' '
      )
      return false

    if 'buy' is bid.side
      if outcome[ otherSide bid.side ].price > parseFloat bid.price
        console.log(
          [
            "+ BUY price"
            pricing.btc( parseFloat bid.price )
            "is less than 24HR SELL"
            pricing.btc( outcome[ otherSide bid.side ].price )
          ].join ' '
        )

        return true


      console.log(
        [
          "proposed BUY price"
          pricing.btc( parseFloat bid.price )
          "is greater than 24HR SELL"
          pricing.btc( outcome[ otherSide bid.side ].price )
        ].join ' '
      )
      return false

  console.log 'BAD SEA STATE', 'fell through', bid, outcome
  false


###
.____           __               .___         __  .__    .__
|    |    _____/  |_  ______   __| _/____   _/  |_|  |__ |__| ______
|    |  _/ __ \   __\/  ___/  / __ |/  _ \  \   __\  |  \|  |/  ___/
|    |__\  ___/|  |  \___ \  / /_/ (  <_> )  |  | |   Y  \  |\___ \
|_______ \___  >__| /____  > \____ |\____/   |__| |___|  /__/____  >
        \/   \/          \/       \/                   \/        \/     \/
###

module.exports = gooderSeaState
