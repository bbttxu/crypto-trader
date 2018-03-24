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
  lensPath
  view
  map
} = require 'ramda'

md5 = require 'blueimp-md5'

assessBids = require '../lib/assessBids'

ensureSellIsMoreThanBuy = require '../lib/ensureSellIsMoreThanBuy'

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

    hahaha = {}

    bids = assessBids( action.bids )

    if bids.sell
      bidsLensPath = lensProp 'sell'
      hahaha = set bidsLensPath, bids.sell.price.q3, hahaha


    if bids.buy
      bidsLensPath = lensProp 'buy'
      hahaha = set bidsLensPath, bids.buy.price.q1, hahaha


    addPriceKey = map ( thing )->
      return
        price: thing

    theLastLaugh = ensureSellIsMoreThanBuy( hahaha )

    currencyLens = lensPath [ 'bids', action.product ]

    state = set currencyLens, addPriceKey( theLastLaugh ), state

    console.log md5 JSON.stringify state

    hashLens = lensProp '_hash'

    state = set hashLens, md5( JSON.stringify state.bids ), state

  state


module.exports = strategicReducer

