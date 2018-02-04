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

publishAdvice = forEachObjIndexed ( advice, currency )->
  adviceChannel.publish "advice:#{currency}", JSON.stringify [ advice ]

_directions = {}
store.subscribe ->
  directions = store.getState().directions

  if not equals _directions, directions
    publishAdvice directions

    _directions = directions


statsChannel.on 'pmessage', ( match, channel, stats )->
  store.dispatch
    type: 'UPDATE'
    stats: JSON.parse stats

statsChannel.psubscribe "stats:*"
