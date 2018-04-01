###
.____    ._____.                      .__
|    |   |__\_ |______________ _______|__| ____   ______
|    |   |  || __ \_  __ \__  \\_  __ \  |/ __ \ /  ___/
|    |___|  || \_\ \  | \// __ \|  | \/  \  ___/ \___ \
|_______ \__||___  /__|  (____  /__|  |__|\___  >____  >
        \/       \/           \/              \/     \/
###

getBids = require './lib/getBids'

catchError = require './lib/catchError'

otherSide = require './lib/otherSide'

assessBids = require './lib/assessBids'

normalizeStatsInputs = require './lib/normalizeStatsInputs'

{
  pick
  map
  where
  filter
  isNil
  isEmpty
  reject
} = require 'ramda'

moment = require 'moment'

ml = require './lib/ml'

###
___________                   __  .__
\_   _____/_ __  ____   _____/  |_|__| ____   ____   ______
 |    __)|  |  \/    \_/ ___\   __\  |/  _ \ /    \ /  ___/
 |     \ |  |  /   |  \  \___|  | |  (  <_> )   |  \\___ \
 \___  / |____/|___|  /\___  >__| |__|\____/|___|  /____  >
     \/             \/     \/                    \/     \/
###

pickImportant = map pick( [ 'time', 'price', 'side', 'size', 'stats', 'id', 'reason' ] )

consoleReturn = ( value )->
  console.log value
  value



findEfficacy = ( list )->

  individualPrice = ( bid )->
    # console.log bid.time

    sideFlag = if bid.side is 'sell' then 1 else 0

    now = moment( bid.time )
    aDayLater = moment( bid.time ).add( 24, 'hours' )

    last24Hours = ( otherBid )->
      otherBidTime = moment( otherBid.time )

      return false if otherBid.side is bid.side

      return true if otherBidTime.isAfter( now ) and otherBidTime.isBefore( aDayLater )

      false


    relevant = filter last24Hours, list

    assessment = assessBids relevant

    output = -1

    if assessment[ otherSide bid.side ]
      average = assessment[ otherSide bid.side ].price.avg

      if 'sell' is bid.side

        if bid.price > average
          output = 1
        else
          output = 0

      if 'buy' is bid.side

        if bid.price < average
          output = 1
        else
          output = 0


      return
        bid: bid
        output: [ output ]
        input: [ sideFlag ].concat normalizeStatsInputs bid.stats

    undefined


  map individualPrice, list


noStats = ( bid )->
  isEmpty( bid.stats ) or isNil( bid.stats )


cutOffDate = moment( '2018-02-01T00:00:00-00:00' )
removeEarlierVersions = filter ( bid )->
  moment( bid.time ).isAfter cutOffDate


###
.____           __               .___         __  .__    .__
|    |    _____/  |_  ______   __| _/____   _/  |_|  |__ |__| ______
|    |  _/ __ \   __\/  ___/  / __ |/  _ \  \   __\  |  \|  |/  ___/
|    |__\  ___/|  |  \___ \  / /_/ (  <_> )  |  | |   Y  \  |\___ \
|_______ \___  >__| /____  > \____ |\____/   |__| |___|  /__/____  >
        \/   \/          \/       \/                   \/        \/     \/
###

getBids(
  'LTC-USD',
  reason: 'filled'
).then(
  removeEarlierVersions
).then(
  reject noStats
).then(
  pickImportant
).then(
  findEfficacy
).then(
  reject isNil
).then(
  ml
).catch(
  catchError( 'db' )
)
