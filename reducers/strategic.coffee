###
.____    ._____.                      .__
|    |   |__\_ |______________ _______|__| ____   ______
|    |   |  || __ \_  __ \__  \\_  __ \  |/ __ \ /  ___/
|    |___|  || \_\ \  | \// __ \|  | \/  \  ___/ \___ \
|_______ \__||___  /__|  (____  /__|  |__|\___  >____  >
        \/       \/           \/              \/     \/
###

{
  set
  lensProp
} = require 'ramda'

# md5 = require 'blueimp-md5'

assessBids = require '../lib/assessBids'

###
.____           __               .___         __  .__    .__
|    |    _____/  |_  ______   __| _/____   _/  |_|  |__ |__| ______
|    |  _/ __ \   __\/  ___/  / __ |/  _ \  \   __\  |  \|  |/  ___/
|    |__\  ___/|  |  \___ \  / /_/ (  <_> )  |  | |   Y  \  |\___ \
|_______ \___  >__| /____  > \____ |\____/   |__| |___|  /__/____  >
        \/   \/          \/       \/                   \/        \/     \/
###

initialState = {}

strategicReducer = ( state, action )->
  if typeof state == 'undefined'
    return initialState

  # console.log action
  if 'UPDATE_STRATEGIC_BIDS' is action.type

    currencyLens = lensProp action.product

    state = set currencyLens, assessBids( action.bids ), state

    console.log state

    # state
    # # match price might not be present if there is still
    # # remaining size for the trade hasn't been filled
    # if action.match.price
    #   lens = lensPath [ 'prices', action.match.product_id, action.match.side ]
    #   state = set lens, action.match.price, state

    #   hashLens = lensProp '_hash'
    #   state = set hashLens, md5( JSON.stringify state.prices ), state

  state


module.exports = strategicReducer

