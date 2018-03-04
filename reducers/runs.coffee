initialState =
  states: {}


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
} = require 'ramda'

md5 = require 'blueimp-md5'

groupBySide = require '../lib/groupBySide'

arrayStats = require '../lib/arrayStats'


###
___________                   __  .__
\_   _____/_ __  ____   _____/  |_|__| ____   ____   ______
 |    __)|  |  \/    \_/ ___\   __\  |/  _ \ /    \ /  ___/
 |     \ |  |  /   |  \  \___|  | |  (  <_> )   |  \\___ \
 \___  / |____/|___|  /\___  >__| |__|\____/|___|  /____  >
     \/             \/     \/                    \/     \/
###

findStats = ( runs )->
  arrayStats pluck 'd_price', runs

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

    # console.log basicRunData action.run

    mergedRuns = currentruns.concat( action.run )

    state = set runsPath, mergedRuns, state

    currencyStats = {}
    currencyStats[ action.product ] = map( findStats, groupBySide( mergedRuns ) )

    state = set statsPath, merge( state.stats, currencyStats ), state

    state = set statsHashPath, md5( JSON.stringify state.stats ), state


    console.log Date.now() - start, 'ms'

  state


module.exports = runsReducer

