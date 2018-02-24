###
.____    ._____.                      .__
|    |   |__\_ |______________ _______|__| ____   ______
|    |   |  || __ \_  __ \__  \\_  __ \  |/ __ \ /  ___/
|    |___|  || \_\ \  | \// __ \|  | \/  \  ___/ \___ \
|_______ \__||___  /__|  (____  /__|  |__|\___  >____  >
        \/       \/           \/              \/     \/
###

{
  # merge
  # groupBy
  # values
  # mapObjIndexed
  # flatten
  # map
  # mergeAll
  # uniq
  # pluck
  lensPath
  set
} = require 'ramda'

# getDirection = require '../lib/getDirection'

# initialState =
#   stats: {}
#   directions: {}


# separateBases = groupBy ( key )->
#   key.product.split( '-' )[1]


# asdf = mapObjIndexed ( value, key )->
#   value.product = key
#   value



# individualDiretion = map ( item )->
#   obj = {}
#   obj[ item.product ] = getDirection item
#   obj


# noTrading = map ( item, a )->
#   obj = {}
#   obj[ item ] = 'hold'
#   obj

# foobar = mapObjIndexed ( value, index )->

#   baseDirections = individualDiretion value

#   directions = uniq values mergeAll values baseDirections

#   if directions.length is 1
#     return baseDirections

#   noTrading pluck 'product', value

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
    lens = lensPath [ action.match.product_id, action.match.side ]
    state = set lens, action.match.price, state


  state

module.exports = pricingReducer

