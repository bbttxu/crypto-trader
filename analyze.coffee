###
.____    ._____.                      .__
|    |   |__\_ |______________ _______|__| ____   ______
|    |   |  || __ \_  __ \__  \\_  __ \  |/ __ \ /  ___/
|    |___|  || \_\ \  | \// __ \|  | \/  \  ___/ \___ \
|_______ \__||___  /__|  (____  /__|  |__|\___  >____  >
        \/       \/           \/              \/     \/
###

getRuns = require './lib/getRunsFromStorage'

catchError = require './lib/catchError'

otherSide = require './lib/otherSide'

assessBids = require './lib/assessBids'

normalizeStatInputs = require './lib/normalizeStatInputs'

normalizeStatsInputs = require './lib/normalizeStatsInputs'

statistics = require 'summary-statistics'

{
  pick
  map
  where
  filter
  isNil
  isEmpty
  reject
  pluck
  uniq
  countBy
  prop
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



quantize = ( value )->
  # console.log ( value || 0 ).toFixed( 2 )
  ( value || 0 ).toFixed( 2 )

findEfficacy = ( list )->

  individualPrice = ( run )->
    return undefined unless run.stats

    return undefined unless run.stats[ run.product_id ]



    # console.log run.stats[ product_id ]

    sideFlag = if run.side is 'sell' then 1 else 0
    # console.log sideFlag

    now = moment( run.end )
    aDayLater = moment( run.end ).add( 24, 'hours' )
    # console.log now.format(), aDayLater.format()

    last24Hours = ( otherBid )->
      otherBidTime = moment( otherBid.end )

      return true if otherBidTime.isAfter( now ) and otherBidTime.isBefore( aDayLater )

      false


    relevant = filter last24Hours, list

    console.log relevant

    return undefined if relevant.length < 5


    if 'sell' is run.side

      stats = statistics pluck 'q3', pluck 'prices', relevant

      output = if ( run.prices.q3 > stats.q3 ) then 1 else 0

      return
        # run: run
        output: [ output ]
        input: map quantize, normalizeStatInputs run.stats[ run.product_id ]

    if 'buy' is run.side

      stats = statistics pluck 'q1', pluck 'prices', relevant

      output = if ( run.prices.q1 > stats.q1 ) then 1 else 0

      return
        # run: run
        output: [ output ]
        input: map quantize, normalizeStatInputs run.stats[ run.product_id ]


    undefined


  map individualPrice, list


cutOffDate = moment( '2018-02-01T00:00:00-00:00' )

removeEarlierVersions = filter ( bid )->
  not isEmpty bid.stats

  # moment( bid.time ).isAfter cutOffDate


###
.____           __               .___         __  .__    .__
|    |    _____/  |_  ______   __| _/____   _/  |_|  |__ |__| ______
|    |  _/ __ \   __\/  ___/  / __ |/  _ \  \   __\  |  \|  |/  ___/
|    |__\  ___/|  |  \___ \  / /_/ (  <_> )  |  | |   Y  \  |\___ \
|_______ \___  >__| /____  > \____ |\____/   |__| |___|  /__/____  >
        \/   \/          \/       \/                   \/        \/     \/
###

getRuns(
  {
    product_id: 'LTC-USD'
    side: 'sell'
  }
).then(
  removeEarlierVersions
# ).then(
#   reject noStats
# ).then(
#   ( results )->
#     console.log results
#     results
# ).then(
#   pickImportant
).then(
  findEfficacy
).then(
  uniq
).then(
  reject isNil
).then(
  ( results )->
    # console.log results
    console.log countBy prop( 'output' ), results
    results
).then(
  ml
).catch(
  catchError( 'db' )
)
