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
  view
  set
  lensProp
} = require 'ramda'

md5 = require 'blueimp-md5'

otherSide = require '../lib/otherSide'


###
.____           __               .___         __  .__    .__
|    |    _____/  |_  ______   __| _/____   _/  |_|  |__ |__| ______
|    |  _/ __ \   __\/  ___/  / __ |/  _ \  \   __\  |  \|  |/  ___/
|    |__\  ___/|  |  \___ \  / /_/ (  <_> )  |  | |   Y  \  |\___ \
|_______ \___  >__| /____  > \____ |\____/   |__| |___|  /__/____  >
        \/   \/          \/       \/                   \/        \/     \/
###

initialState = {}

pricingReducer = ( state, action )->
  if typeof state == 'undefined'
    return initialState

  if 'UPDATE_PRICING' is action.type
    # match price might not be present if there is still
    # remaining size for the trade hasn't been filled
    if action.match.price

      other = lensPath [ 'prices', action.match.product_id, otherSide( action.match.side ) ]
      otherPrice = view other, state

      # we want to make sure that we set price as min of the two prices found
      # it's not always the way we expectPRICES
      if otherPrice
        buyLens = lensPath [ 'prices', action.match.product_id, 'buy' ]
        sellLens = lensPath [ 'prices', action.match.product_id, 'sell' ]

        state = set buyLens, Math.min( action.match.price, otherPrice ), state
        state = set sellLens, Math.max( action.match.price, otherPrice ), state

      # just set the price if it's the only side
      else
        lens = lensPath [ 'prices', action.match.product_id, action.match.side ]
        state = set lens, ( action.match.price ), state

      hashLens = lensProp '_hash'
      state = set hashLens, md5( JSON.stringify state.prices ), state

  state


module.exports = pricingReducer

