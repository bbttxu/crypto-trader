log = require './lib/log'

Redis = require 'ioredis'

statsChannel = new Redis()

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
  equals
  forEachObjIndexed
} = require 'ramda'

{ createStore, applyMiddleware } = require 'redux'
thunk = require 'redux-thunk'

getDirection = require './lib/getDirection'


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

reducer = ( state, action )->
  if typeof state == 'undefined'
    return initialState

  if 'UPDATE' is action.type
    state.stats = merge state.stats, action.stats

    bases = separateBases flatten values asdf state.stats

    state.directions = mergeAll flatten values foobar bases

  state


store = createStore reducer, applyMiddleware(thunk.default)


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
