###
.____    ._____.                      .__
|    |   |__\_ |______________ _______|__| ____   ______
|    |   |  || __ \_  __ \__  \\_  __ \  |/ __ \ /  ___/
|    |___|  || \_\ \  | \// __ \|  | \/  \  ___/ \___ \
|_______ \__||___  /__|  (____  /__|  |__|\___  >____  >
        \/       \/           \/              \/     \/
###

log = require './lib/log'

Redis = require 'ioredis'

statsChannel = new Redis()

{
  equals
  forEachObjIndexed
} = require 'ramda'

{
  createStore
  applyMiddleware

} = require 'redux'

thunk = require 'redux-thunk'

brainReducer = require './reducers/brainReducer'


###
.____           __               .___         __  .__    .__
|    |    _____/  |_  ______   __| _/____   _/  |_|  |__ |__| ______
|    |  _/ __ \   __\/  ___/  / __ |/  _ \  \   __\  |  \|  |/  ___/
|    |__\  ___/|  |  \___ \  / /_/ (  <_> )  |  | |   Y  \  |\___ \
|_______ \___  >__| /____  > \____ |\____/   |__| |___|  /__/____  >
        \/   \/          \/       \/                   \/        \/     \/
###

store = createStore brainReducer, applyMiddleware(thunk.default)

adviceChannel = new Redis()

publishAdvice = ( advice )->
  adviceChannel.publish "advice", JSON.stringify advice


_directions_hash = 'undefined_directions_hash'
store.subscribe ->
  directions_hash = store.getState()._hash
  unless equals _directions_hash, directions_hash
    publishAdvice store.getState().directions
    console.log 'directions', directions_hash

    _directions_hash = directions_hash

pushMinuteUpdates = ->
  if store.getState().directions
    publishAdvice store.getState().directions

setInterval pushMinuteUpdates, 60 * 1000

statsChannel.on 'pmessage', ( match, channel, stats )->
  store.dispatch
    type: 'UPDATE'
    stats: JSON.parse stats

statsChannel.psubscribe "stats:*"
