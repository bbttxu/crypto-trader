###
.____    ._____.                      .__
|    |   |__\_ |______________ _______|__| ____   ______
|    |   |  || __ \_  __ \__  \\_  __ \  |/ __ \ /  ___/
|    |___|  || \_\ \  | \// __ \|  | \/  \  ___/ \___ \
|_______ \__||___  /__|  (____  /__|  |__|\___  >____  >
        \/       \/           \/              \/     \/
###

{
  lensPath
  set
  lensProp
} = require 'ramda'

md5 = require 'blueimp-md5'


###
.____           __               .___         __  .__    .__
|    |    _____/  |_  ______   __| _/____   _/  |_|  |__ |__| ______
|    |  _/ __ \   __\/  ___/  / __ |/  _ \  \   __\  |  \|  |/  ___/
|    |__\  ___/|  |  \___ \  / /_/ (  <_> )  |  | |   Y  \  |\___ \
|_______ \___  >__| /____  > \____ |\____/   |__| |___|  /__/____  >
        \/   \/          \/       \/                   \/        \/     \/
###

initialState = {}

adviceReducer = ( state, action )->
  if typeof state == 'undefined'
    return initialState

  if 'UPDATE_ADVICE' is action.type
    # match price might not be present if there is still
    # remaining size for the trade hasn't been filled
    # if action.match.price
    #   lens = lensPath [ 'prices', action.match.product_id, action.match.side ]
    #   state = set lens, action.match.price, state

    #   hashLens = lensProp '_hash'
    #   state = set hashLens, md5( JSON.stringify state.prices ), state

    console.log action

  state


module.exports = adviceReducer

