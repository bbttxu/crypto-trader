###
.____    ._____.                      .__
|    |   |__\_ |______________ _______|__| ____   ______
|    |   |  || __ \_  __ \__  \\_  __ \  |/ __ \ /  ___/
|    |___|  || \_\ \  | \// __ \|  | \/  \  ___/ \___ \
|_______ \__||___  /__|  (____  /__|  |__|\___  >____  >
        \/       \/           \/              \/     \/
###

md5 = require 'blueimp-md5'

{
  set
  lensPath
  view
  # props
  pluck
  min
  max
  add
  toString
  map
  omit
  multiply
  reverse
} = require 'ramda'

###
.____           __               .___         __  .__    .__
|    |    _____/  |_  ______   __| _/____   _/  |_|  |__ |__| ______
|    |  _/ __ \   __\/  ___/  / __ |/  _ \  \   __\  |  \|  |/  ___/
|    |__\  ___/|  |  \___ \  / /_/ (  <_> )  |  | |   Y  \  |\___ \
|_______ \___  >__| /____  > \____ |\____/   |__| |___|  /__/____  >
        \/   \/          \/       \/                   \/        \/     \/
###


update = ( saved, current )->
  unless saved
    return map parseFloat, [ current.price, current.price, current.price, current.price, current.size ]

  return [
    parseFloat min saved[0], current.price
    parseFloat max saved[1], current.price
    saved[2]
    parseFloat current.price
    add saved[4], current.size
  ]



initialState = {}

candlesReducer = ( state, action )->
  return initialState if typeof state == 'undefined'

  if 'ADD_MATCH' is action.type
    match = action.match

    runNumber = ( number )->
      index = parseInt match.timestamp / ( number * 1000 )
      path = [
        match.product_id
        toString( number )
        toString( index )
      ]

      lens = lensPath path

      saved = view lens, state

      updated = update saved, match

      state = set( lens, updated, state )

    map runNumber, [
      60
      300
      900
      3600
      21600
      86400
    ]

  state._hash = md5 JSON.stringify omit ['_hash'], state
  state


module.exports = candlesReducer

