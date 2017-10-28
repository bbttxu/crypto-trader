

PRODUCT_ID = 'BTC-USD'
# PRODUCT_ID = 'ETH-BTC'

SIZING = 100


RSVP = require 'rsvp'

log = require './lib/log'

handleFractionalSize = require './lib/handleFractionalSize'

gdax = require './lib/gdax-client'



require('dotenv').config( silent: true )
mongoConnection = require('./lib/mongoConnection')

cleanUpTrade = require './lib/cleanUpTrades'

{
  map
  pick
  sum
  isEmpty
  all
  propEq
  equals
  filter
  head
  pluck
  all
  last
  keys
  where
  groupBy
  prop
  mapObjIndexed
  forEachObjIndexed
  lensPath
  view
  merge
  set
  mergeAll
  findIndex
  addIndex
  sort
  reject
} = require 'ramda'



initalState =
  tick: 0
  fills: []
  ratio: 0
  progress: 0
  top: {}
  bottom: {}
  run: []
  runs: []
  sell: {}
  buy: {}
  bid: {}
  bids: []
  match: {}




addBid = ( bid, cancelPlease )->
  log 'bid'
  log bid
  log cancelPlease

  log bid

  onGood = ( foo )->
    message = foo.body

    if message.message
      console.log 'message.message', message.message

    else
      store.dispatch
        type: 'ADD_BID'
        bid: merge( JSON.parse( foo.body ), bid )


  onError = ( err )->
    console.log 'sell onError'
    console.log 'error', err, err.body

  console.log 'start', bid.side,  'bid'

  console.log '!!!', bid, '!!!'
  gdax[bid.side]( bid ).then( onGood ).catch( onError )


  console.log 'cancelPlease', cancelPlease


decisioner = require './lib/decisioner'




asdf = ( fill )->
  value = fill.price * fill.size

  if fill.side is 'buy'
    value = -1.0 * value

  value

progress = ( data )->
  a = map asdf, data


{ createStore, applyMiddleware } = require 'redux'
thunk = require 'redux-thunk'

moment = require 'moment'

consolidateRun = require './consolidateRun'

averageOf = require './lib/averageOf'

makeNewBid = ( bid, cancelPlease )->
  if decisioner( bid )
    console.log 'decisioned okay', bid.bid.size, bid.bid
    if handleFractionalSize bid.bid
      console.log 'passed fractional size', bid.bid.size, bid.bid

      if bid.bid.size < 0.01
        bid.bid.size = 0.01


      addBid bid.bid


  makeCancellation = ( cancelThisID )->
    # for hashes
    obj = {}
    obj[ cancelThisID ] = gdax.cancelOrder( cancelThisID )
    obj




  RSVP.hashSettled( mergeAll map makeCancellation, cancelPlease ).then( ( good )->


    #
    isFullfilled = ( outcome )->
      true is outcome.value

    fulfilled = filter isFullfilled, good

    #
    cancelBid = ( bid, id )->
      console.log 'bid', bid, id

      if true is bid.value

        payload =
          type: 'BID_CANCELLED'
          id: id


        store.dispatch payload


    forEachObjIndexed cancelBid, good



  ).catch( (error)->
    console.log 'really bad thing', error
  )


reducer = (state, action) ->
  if typeof state == 'undefined'
    return initalState


  if 'HEARTBEAT' is action.type
    start = Date.now()

    # do stuff here
    console.log 'HEARTBEAT', start, Date.now() - start


  if 'BID_CANCELLED' is action.type
    state.bids = reject propEq( 'id', action.id ), state.bids
    console.log 'BID_CANCELLED', action.id, state.bids








  if 'UPDATE_TOP' is action.type
    state.top = action.data


  if 'UPDATE_BOTTOM' is action.type
    state.bottom = action.data


  state.sellAmount = state.top.available / SIZING


  state.buyAmount = state.bottom.available / state.sell.price / SIZING

  if 'ADD_BID' is action.type
    console.log 'ADD_BID', JSON.stringify action.bid

    state.bids.push action.bid

    console.log 'ADD_BID'



  if 'ADD_RUN' is action.type
    state.runs.push action.run




  if 'ADD_MATCH' is action.type

    state.match = action.match

    # keep around until goodSeaState uses .match only
    state.side = action.match.side

    skinny = ( data )->
      data.timestamp = moment( data.time ).valueOf()
      pick [
        'side',
        'size',
        'price',
        'sequence',
        # 'time',
        'timestamp'
      ], data


    state[ action.match.side ] = merge state[ action.match.side ], pick [ 'price', 'sequence', 'timestamp' ], action.match


    unless isEmpty state.run

      sameSide = ( runners )->
        runners.side is action.match.side


      importantValue = all sameSide, state.run

      if importantValue
        state.run.push skinny action.match


      unless importantValue
        # Don't use runs that are only one fill long
        if state.run.length > 1
          console.log 'new run', JSON.stringify consolidateRun state.run, PRODUCT_ID


          saveRun state.run

        state.run = []


    if isEmpty state.run
      state.run = [ skinny action.match ]


      bidPrice =
        parseFloat( ( skinny action.match ).price ) +
        2.0 * parseFloat( state[ ( skinny action.match ).side ].d_price )

      bid = cleanUpTrade
        price: bidPrice
        side: action.match.side
        product_id: PRODUCT_ID
        size: state["#{action.match.side}Amount"]


      lkfafdijwe = state[ action.match.side ]

      iuwoiqe = merge lkfafdijwe, bid: bid

      if 'sell' is action.match.side
        state.sell = iuwoiqe

      if 'buy' is action.match.side
        state.buy = iuwoiqe



    action.match.timestamp = moment( action.match.time ).valueOf()

    if 'sell' is action.match.side
      matchKeys = [
        'price'
        'sequence'
        'time'
        'timestamp'
      ]


      state.sell = merge state.sell, pick keys, action.match
      state.sellPrice = state.sell.price

    if 'buy' is action.match.side
      matchKeys = [
        'price'
        'sequence'
        'time'
        'timestamp'
      ]


      state.buy = merge state.buy, pick matchKeys, action.match
      state.buyPrice = state.buy.price

    unless importantValue

      makeNewBid(
        state[action.match.side],
        pluck 'id', state.bids
      )

  if state.top and state.sell
    state.topValue = state.sell.price * state.top.available


  if state.bottom and state.buy
    state.buyPrice = state.bottom.available


  if 'FILL_ADDED' is action.type
    state.fills.push action.fill


  state.progress = sum progress state.fills
  state.volume = sum map Math.abs, progress state.fills

  state.ratio = state.progress / state.volume



  determineMiddle = ( runs, side )->
    n = sum pluck 'n', runs
    n_runs = runs.length

    response =
      d_time: averageOf( 'd_time' )( runs )
      d_price: averageOf( 'd_price' )( runs )
      d_volume: averageOf( 'volume' )( runs )
      n: n
      n_runs: n_runs
      n_runs_ratio: n / n_runs


  mergeIntoState = ( data, side )->
    state[side] = merge state[side], data


  forEachObjIndexed mergeIntoState, mapObjIndexed determineMiddle, groupBy prop( 'side' ), state.runs


  #
  #  tick it
  state.tick = 1 + state.tick
  state

store = createStore reducer, applyMiddleware(thunk.default)

saveRunToStorage = require './lib/saveRunToStorage'

saveRun = ( run )->
  consolidated = consolidateRun run, PRODUCT_ID

  saveRunToStorage( consolidated ).then( (good)->
    store.dispatch
      type: 'ADD_RUN'
      run: consolidated
  ).catch( (err)->
    console.log 'err', err
  )

getRunsFromStorage = require './lib/getRunsFromStorage'


addRun = ( run, index )->
  storeDispatch = ->
    store.dispatch
      type: 'ADD_RUN'
      run: run

  setTimeout storeDispatch, index * 100


sortByAbsSize = ( a, b )->
  Math.abs( prop 'd_price', b ) - Math.abs( prop 'd_price', a )


getRunsFromStorage(
  product_id: PRODUCT_ID
).then( (result)->
  addIndex( map ) addRun, sort sortByAbsSize, result
).catch( (error)->
  console.log error
)



###
  ___ ___ .__       .__              .____
 /   |   \|__| ____ |  |__           |    |    ______  _  __
/    ~    \  |/ ___\|  |  \   ______ |    |   /  _ \ \/ \/ /
\    Y    /  / /_/  >   Y  \ /_____/ |    |__(  <_> )     /
 \___|_  /|__\___  /|___|  /         |_______ \____/ \/\_/
       \/   /_____/      \/                  \/
###


updateAccountTotals = ( product_id )->
  parts = product_id.split '-'

  topKey = parts[0]
  bottomKey = parts[1]


  matchCurrency = ( currency )->
    ( record )->
      currency is record.currency


  dispatchCurrency = ( currency )->
    ( record )->
      store.dispatch
        type: currency
        data: record


  new RSVP.Promise ( resolve, reject )->
    gdax.getAccounts( product_id ).then ( result )->
      dispatchCurrency( 'UPDATE_TOP' ) head filter matchCurrency( topKey ), result
      dispatchCurrency( 'UPDATE_BOTTOM' ) head filter matchCurrency( bottomKey ), result





Stream = require './lib/stream'

productStream = Stream PRODUCT_ID

productStream.subscribe "message:#{PRODUCT_ID}", ( hi )->
  if 'match' is hi.type
    store.dispatch
      type: 'ADD_MATCH'
      match: hi







start = ( product_id )->

  onSuccess = ( result )->
    # console.log 'start onSuccess', result

  onError = ( error )->
    console.log 'start onError', error

  init = ->
    updateAccountTotals( product_id ).then( onSuccess ).catch( onError )


  init()

  setInterval init, 60 * 1000


  onError = (fail)->
    console.log 'fail', fail
    reject fail


  mongoConnection().then(onSuccess).catch(onError)


_throttle = require 'lodash.throttle'

past = undefined

updatedStore = ->
  state = store.getState()
  importantKeys = [
    # 'progress'
    # 'volume'
    # 'ratio'
    'bottom'
    'sell'
    # 'topValue'
    'top'
    'buy'
    'buyPrice'
    # 'runs'
    # 'tick'
    # 'run'
    # 'buyAmount'
    # 'sellAmount'
    'bids'
    # 'fills'
  ]
  # importantKeys = [ 'tick', 'prices', 'matches' ]
  # importantKeys = [ 'tick', 'prices', 'projections' ]
  important = pick importantKeys, state

  if past
    if past isnt important
      log important
      past = important

  unless past
    past = important


# store.subscribe _throttle updatedStore, 10000

start( PRODUCT_ID )



pulse = ->
  store.dispatch
    type: 'HEARTBEAT'
setTimeout (->
  setInterval pulse, 60 * 1000
), 60 * 1000
