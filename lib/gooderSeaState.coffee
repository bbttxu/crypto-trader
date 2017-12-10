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

###
___________                   __  .__
\_   _____/_ __  ____   _____/  |_|__| ____   ____   ______
 |    __)|  |  \/    \_/ ___\   __\  |/  _ \ /    \ /  ___/
 |     \ |  |  /   |  \  \___|  | |  (  <_> )   |  \\___ \
 \___  / |____/|___|  /\___  >__| |__|\____/|___|  /____  >
     \/             \/     \/                    \/     \/
###


groupBySide = groupBy prop 'side'

deValue = ( bid )->
  now = moment().unix()

  return bid unless bid.created_at

  andThen = moment( bid.created_at ).unix()

  DATE = 86400

  decay = ( DATE - ( now - andThen ) )/ DATE

  decayedSize = ( clamp 0, 1, decay * ( parseFloat bid.size ) ).toFixed 4

  bid.size = decayedSize

  bid



getValue = ( bid )->
  ( parseFloat bid.price ) * ( parseFloat bid.size )

getSideSum = map ( side )->
  sideSum =
    sum: sum map getValue, side
    size: sum map parseFloat, map prop( 'size' ), side


  sideSum.price = sideSum.sum / sideSum.size
  sideSum.n = side.length
  sideSum


gooderSeaState = ( bids, bid )->
  console.log bids, bid

  outcome = getSideSum groupBySide map(
    pick ['id', 'side', 'size', 'price', 'created_at']

    filter(
      ( bid )->
        'filled' is bid.reason
      ,
      bids
    )
  )

  if bid and bid.side and outcome[ otherSide bid.side ] and not isEmpty outcome[ otherSide bid.side ]
    if 'sell' is bid.side
      return outcome[ otherSide bid.side ].price < bid.price

    if 'buy' is bid.side
      return outcome[ otherSide bid.side ].price > bid.price


  console.log 'BAD SEA STATE', bid, bids
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
