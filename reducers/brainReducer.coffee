###
.____    ._____.                      .__
|    |   |__\_ |______________ _______|__| ____   ______
|    |   |  || __ \_  __ \__  \\_  __ \  |/ __ \ /  ___/
|    |___|  || \_\ \  | \// __ \|  | \/  \  ___/ \___ \
|_______ \__||___  /__|  (____  /__|  |__|\___  >____  >
        \/       \/           \/              \/     \/
###

{
  merge
  groupBy
  values
  mapObjIndexed
  flatten
  map
  mergeAll
  uniq
  pluck
  lensProp
  set
} = require 'ramda'

md5 = require 'blueimp-md5'

getDirection = require '../lib/getDirection'

initialState =
  stats: {}
  directions: {}


separateBases = groupBy ( key )->
  key.product.split( '-' )[1]


asdf = mapObjIndexed ( value, key )->
  value.product = key
  value



individualDiretion = map ( item )->
  obj = {}
  obj[ item.product ] = getDirection item
  obj


noTrading = map ( item, a )->
  obj = {}
  obj[ item ] = 'hold'
  obj

foobar = mapObjIndexed ( value, index )->

  baseDirections = individualDiretion value

  directions = uniq values mergeAll values baseDirections

  if directions.length is 1
    return baseDirections

  noTrading pluck 'product', value

###
.____           __               .___         __  .__    .__
|    |    _____/  |_  ______   __| _/____   _/  |_|  |__ |__| ______
|    |  _/ __ \   __\/  ___/  / __ |/  _ \  \   __\  |  \|  |/  ___/
|    |__\  ___/|  |  \___ \  / /_/ (  <_> )  |  | |   Y  \  |\___ \
|_______ \___  >__| /____  > \____ |\____/   |__| |___|  /__/____  >
        \/   \/          \/       \/                   \/        \/     \/
###

brainReducer = ( state, action )->
  if typeof state == 'undefined'
    return initialState

  if 'UPDATE' is action.type
    state.stats = merge state.stats, action.stats

    # console.log state.stats

    bases = separateBases flatten values asdf state.stats

    state.directions = mergeAll flatten values foobar bases

    hashLens = lensProp '_hash'
    state = set hashLens, md5( JSON.stringify state.directions ), state


  state

module.exports = brainReducer

