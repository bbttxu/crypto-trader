JOB = 'CURRENCY_SIDE_ML'

counter = 0


###
.____    ._____.                      .__
|    |   |__\_ |______________ _______|__| ____   ______
|    |   |  || __ \_  __ \__  \\_  __ \  |/ __ \ /  ___/
|    |___|  || \_\ \  | \// __ \|  | \/  \  ___/ \___ \
|_______ \__||___  /__|  (____  /__|  |__|\___  >____  >
        \/       \/           \/              \/     \/
###

kue = require 'kue'

getRuns = require '../lib/getRunsFromStorage'

catchError = require '../lib/catchError'

otherSide = require '../lib/otherSide'

assessBids = require '../lib/assessBids'

normalizeStatInputs = require '../lib/normalizeStatInputs'

normalizeStatsInputs = require '../lib/normalizeStatsInputs'

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
  groupBy
  omit
} = require 'ramda'

moment = require 'moment'

ml = require '../lib/ml'

###
___________                   __  .__
\_   _____/_ __  ____   _____/  |_|__| ____   ____   ______
 |    __)|  |  \/    \_/ ___\   __\  |/  _ \ /    \ /  ___/
 |     \ |  |  /   |  \  \___|  | |  (  <_> )   |  \\___ \
 \___  / |____/|___|  /\___  >__| |__|\____/|___|  /____  >
     \/             \/     \/                    \/     \/
###

queue = kue.createQueue()

pickImportant = map pick( [ 'time', 'price', 'side', 'size', 'stats', 'id', 'reason' ] )

consoleReturn = ( value )->
  console.log value
  value

addMLToQueue = ( bid )->
  queue.create(
    JOB,
    {
      product_id: bid
      title: bid
    }
  ).attempts(
    5
  ).backoff(
    { type: 'exponential' }
  ).removeOnComplete( true ).save()


quantize = ( value )->
  # console.log ( value || 0 ).toFixed( 3 )
  ( value || 0 ).toFixed( 2 )


splitIntoDataAndTrainingSet = ( data )->
  twentyFourHoursAgo = moment().subtract 24, 'hours'
  fourtyEightHoursAgo = moment().subtract 48, 'hours'

  start = moment( data.start )
  return 'discard' if start.isAfter twentyFourHoursAgo
  return 'training' if start.isAfter fourtyEightHoursAgo
  'data'


findEfficacy = ( list )->

  individualPrice = ( run )->
    return undefined unless run.stats

    return undefined unless run.stats[ run.product_id ]

    run_product_id = run.product_id
    # run_product_id = 'LTC-BTC'

    return undefined unless run.stats[ run_product_id ]

    sideFlag = if run.side is 'sell' then 1 else 0

    now = moment( run.end )
    aDayLater = moment( run.end ).add( 24, 'hours' )

    last24Hours = ( otherBid )->
      otherBidTime = moment( otherBid.end )

      return true if otherBidTime.isAfter( now ) and otherBidTime.isBefore( aDayLater )

      false


    relevant = filter last24Hours, list

    return undefined if relevant.length < 5


    if 'sell' is run.side
      stats = statistics pluck 'q3', pluck 'prices', relevant

      output = if ( run.prices.q3 > stats.q3 ) then 1 else 0

      return
        run: run
        output: [ output ]
        input: map quantize, normalizeStatInputs run.stats[ run_product_id ]


    # assessment = assessBids relevant

    # output = -1

    # if assessment[ otherSide run.side ]
    #   average = assessment[ otherSide run.side ].price.avg

    #   if 'sell' is run.side

    #     if run.price > average
    #       output = 1
    #     else
    #       output = 0

    #   if 'buy' is run.side

    #     if run.price < average
    #       output = 1
    #     else
    #       output = 0


    #   return
    #     run: run
    #     output: [ output ]
    #     input: [ sideFlag ].concat normalizeStatsInputs run.stats

    undefined


  map individualPrice, list


# noStats = ( bid )->
#   isEmpty( bid.stats ) or isNil( bid.stats )


cutOffDate = moment( '2018-02-01T00:00:00-00:00' )

removeEarlierVersions = filter ( bid )->
  not isEmpty bid.stats

  # moment( bid.time ).isAfter cutOffDate

saveMLToStorage = ( bid, callback )->
  console.log 'start saveMLToStorage', bid.data
  getRuns(
    {
      product_id: bid.data.product_id
      side: 'sell'
    }
  ).then(
    removeEarlierVersions
  ).then(
    groupBy splitIntoDataAndTrainingSet
  # ).then(
  #   ( results )->
  #     console.log results
  #     results
  ).then(
    omit [ 'discard' ]
  ).then(
    map findEfficacy
  ).then(
    map uniq
  ).then(
    map reject isNil
  # ).then(
  #   ( results )->
  #     console.log results
  #     console.log map countBy prop( 'output' ), results
  #     results
  ).then(
    ml
  ).catch(
    catchError( 'db' )
  ).finally(
    ->
      console.log 'done'
      setTimeout callback, 60 * 1000
  )


queue.on 'error', ( error )->
  console.log JOB, 'ERROR', error

process = ->
  queue.process(
    JOB,
    saveMLToStorage
  )


###
.____           __               .___         __  .__    .__
|    |    _____/  |_  ______   __| _/____   _/  |_|  |__ |__| ______
|    |  _/ __ \   __\/  ___/  / __ |/  _ \  \   __\  |  \|  |/  ___/
|    |__\  ___/|  |  \___ \  / /_/ (  <_> )  |  | |   Y  \  |\___ \
|_______ \___  >__| /____  > \____ |\____/   |__| |___|  /__/____  >
        \/   \/          \/       \/                   \/        \/     \/
###


module.exports =
  process: process
  addMLToQueue: addMLToQueue
