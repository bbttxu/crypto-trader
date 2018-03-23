initialState =
  stats: {}
  runs: []
  run: []


###
.____    ._____.                      .__
|    |   |__\_ |______________ _______|__| ____   ______
|    |   |  || __ \_  __ \__  \\_  __ \  |/ __ \ /  ___/
|    |___|  || \_\ \  | \// __ \|  | \/  \  ___/ \___ \
|_______ \__||___  /__|  (____  /__|  |__|\___  >____  >
        \/       \/           \/              \/     \/
###

moment = require 'moment'

{
  map
  prop
} = require 'sanctuary'

{
  lensPath
  view
  set
  sortBy
  pluck
  merge
  lensProp
  pick
  isEmpty
  all
} = require 'ramda'

statistics = require 'summary-statistics'

md5 = require 'blueimp-md5'

groupBySide = require '../lib/groupBySide'

# arrayStats = require '../lib/arrayStats'

consolidate = require '../lib/consolidateRun'

{
  addRunToQueue
} = require '../workers/saveRunToStorage'

###
___________                   __  .__
\_   _____/_ __  ____   _____/  |_|__| ____   ____   ______
 |    __)|  |  \/    \_/ ___\   __\  |/  _ \ /    \ /  ___/
 |     \ |  |  /   |  \  \___|  | |  (  <_> )   |  \\___ \
 \___  / |____/|___|  /\___  >__| |__|\____/|___|  /____  >
     \/             \/     \/                    \/     \/
###

skinny = ( data )->
  data.timestamp = moment( data.time ).valueOf()
  pick [
    'side',
    'size',
    'price',
    'sequence',
    # 'time',
    'timestamp'
  ], data


findStats = ( runs )->
  statistics pluck 'd_price', runs

# sortByCreatedAt = sortBy prop( 'start' )

# basicRunData = pick [ '_id', 'd_price', 'side', 'start' ]

###
.____           __               .___         __  .__    .__
|    |    _____/  |_  ______   __| _/____   _/  |_|  |__ |__| ______
|    |  _/ __ \   __\/  ___/  / __ |/  _ \  \   __\  |  \|  |/  ___/
|    |__\  ___/|  |  \___ \  / /_/ (  <_> )  |  | |   Y  \  |\___ \
|_______ \___  >__| /____  > \____ |\____/   |__| |___|  /__/____  >
        \/   \/          \/       \/                   \/        \/     \/
###


runsReducer = ( state, action )->
  if typeof state == 'undefined'
    return initialState


  if 'ADD_RUN_FROM_STORAGE' is action.type
    start = Date.now()

    runsPath = lensPath [ action.product, 'runs' ]
    statsPath = lensProp 'stats'
    statsHashPath = lensProp 'stats_hash'

    currentruns = view( runsPath, state ) || []

    # console.log action.run._id

    mergedRuns = currentruns.concat( action.run )

    state = set runsPath, mergedRuns, state

    currencyStats = {}
    currencyStats[ action.product ] = map( findStats, groupBySide( mergedRuns ) )

    state = set statsPath, merge( state.stats, currencyStats ), state

    state = set statsHashPath, md5( JSON.stringify state.stats ), state


    # console.log Date.now() - start, 'ms'


  if 'ADD_MATCH' is action.type
    # console.log action.match, action.match.product_id

    runPath = lensPath [ action.match.product_id, 'run' ]

    run = view( runPath, state ) or []


    if isEmpty run
      # console.log 'EMPTY!'
      state = set( runPath, [ skinny action.match ], state )

    else

      sameSide = ( runners )->
        runners.side is action.match.side


      allInTheSameGang = all sameSide, run

      # console.log action.match.product_id, run.length, 'allInTheSameGang', allInTheSameGang

      if allInTheSameGang is true
        state = set( runPath, run.concat( skinny action.match ), state )

      else
        runPath = lensPath [ action.match.product_id, 'run' ]
        currentRun = view runPath, state or []

        state = set( runPath, [ skinny action.match ], state )

        newRun = consolidate currentRun, action.match.product_id

        if newRun.n > 1

          addRunToQueue newRun

          runsPath = lensPath [ action.match.product_id, 'runs' ]
          statsPath = lensProp 'stats'
          statsHashPath = lensProp 'stats_hash'

          currentruns = view( runsPath, state ) || []


          mergedRuns = currentruns.concat( newRun )

          state = set runsPath, mergedRuns, state

          currencyStats = {}
          currencyStats[ action.match.product_id ] = map( findStats, groupBySide( mergedRuns ) )

          state = set statsPath, merge( state.stats, currencyStats ), state

          state = set statsHashPath, md5( JSON.stringify state.stats ), state


  state


module.exports = runsReducer

