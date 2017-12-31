require( 'dotenv' ).config( silent: true )
argv = require('minimist')(process.argv.slice(2))
PRODUCT_ID = process.env.PRODUCT_ID ||  argv._[0]
DELAY = process.env.DELAY || 3

unless PRODUCT_ID
  console.log 'need a product id!'

SIZING = 100


kue = require 'kue'

queue = kue.createQueue()

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
  sortBy
  contains
  values
  uniq
  isNil
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
  bid_ids: []
  match: {}
  sellFactor: 0
  buyFactor: 0

showStatus = require './lib/showStatus'

saveBidToStorage = ( bid ) ->
  queue.create(
    'SAVE_BID_TO_STORAGE',
    bid
  ).attempts(
    3
  ).backoff(
    { type:'exponential' }
  ).save()

updateBid = require './lib/updateBid'

addBid = ( bid, cancelPlease )->

  # TODO make an optional flag so we can listen and record, but not trade
  # return 1

  onGood = ( foo )->
    message = foo.body

    if message.message
      console.log 'message.message', message.message

    else
      store.dispatch
        type: 'ADD_BID'
        bid: merge( JSON.parse( foo.body ), bid )

    merge( JSON.parse( foo.body ), bid )


  onError = ( err )->
    console.log 'bid.side', bid.side, 'onError'
    console.log 'error', err, err.body

  # console.log 'start', bid.side, 'bid', bid

  gdax[ bid.side ](
    bid
  ).then(
    onGood
  ).catch(
    onError
  )



decisioner = require './lib/decisioner'
# goodSeaState = require './lib/goodSeaState'
gooderSeaState = require './lib/gooderSeaState'



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
  if handleFractionalSize bid
    # console.log 'passed fractional size', bid.size

    if bid.size < 0.01
      bid.size = 0.01


    addBid bid


  makeCancellation = ( cancelThisID )->
    # for hashes
    obj = {}
    obj[ cancelThisID ] = gdax.cancelOrder( cancelThisID )
    obj



  # since we're catching cancellations on the stream, we
  # don't really care of the outcome
  RSVP.hashSettled( mergeAll map makeCancellation, cancelPlease ).then( ( good )->


    #
    isFullfilled = ( outcome )->
      true is outcome.value

    fulfilled = filter isFullfilled, good


    #
    # cancelBid = ( bid, id )->
    #   if true is bid.value
    #     payload =
    #       type: 'BID_CANCELLED'
    #       id: id
    #       bid: bid


    #     store.dispatch payload

    #   if 'order not found' is bid.reason
    #     payload =
    #       type: 'BID_CANCELLED'
    #       id: id
    #       bid: bid


    #     store.dispatch payload


    # forEachObjIndexed cancelBid, good



  ).catch( (error)->
    console.log 'really bad thing', error
  )


reducer = (state, action) ->
  if typeof state == 'undefined'
    return initalState


  if 'HEARTBEAT' is action.type
    start = Date.now()

    # do stuff here vvv

    state.fills = sortBy prop( 'trade_id' ), state.fills
    console.log 'showStatus', showStatus state.fills

    overADayOld = ( run )->
      moment().subtract( 1, 'day' ).valueOf() > run.end

    state.runs = sortBy prop( 'start' ), reject overADayOld, state.runs

    overADayOldBids = ( bid )->
      moment().subtract( 1, 'day' ) > moment( bid.time )

    state.bids = reject overADayOldBids, state.bids

    # do stuff here ^^^

    console.log moment( start ).format(),'HEARTBEAT', Date.now() - start, 'ms'


  if 'UPDATE_FACTORS' is action.type
    state.sellFactor = action.factors.sellFactor
    state.buyFactor = action.factors.buyFactor


  if 'UPDATE_TOP' is action.type
    state.top = action.data


  if 'UPDATE_BOTTOM' is action.type
    state.bottom = action.data


  state.sellAmount = ( state.top.available / SIZING ) * state.sellFactor

  state.buyAmount = ( state.bottom.available / state.sell.price / SIZING ) * parseFloat( state.buyFactor )




  if 'ADD_BID' is action.type
    bid = pick(
      [
        'id',
        'product_id',
        'price',
        'size',
        'side'
      ],
      action.bid
    )



    state.bids.push action.bid
    state.bid_ids = pluck 'id', state.bids


  if 'ADD_RUN' is action.type
    unless 0 is action.run.d_price or 0 is action.run.d_time
      # console.log 'ADD_RUN', state.runs.length, moment( action.run.end ).fromNow()
      state.runs.push action.run


  if 'ADD_FILL' is action.type
    state.fills.push action.fill


  if 'BID_CANCELLED' is action.type

    index = findIndex propEq( 'id', action.bid.order_id ), state.bids

    if index > -1
      # console.log 'BID_CANCELLED', action.bid.order_id, action.bid
      updatedBid = merge state.bids[ index ], action.bid

      state.bids = reject propEq( 'id', action.bid.order_id ), state.bids

      state.bids.push updatedBid

      state.bid_ids = pluck 'id', state.bids

      saveBidToStorage updatedBid




  if 'MATCH_FILLED' is action.type
    # console.log 'MATCH_FILLED', JSON.stringify action.match

    index = findIndex propEq( 'id', action.match.order_id ), state.bids

    if index > -1
      console.log 'MATCH_FILLED', JSON.stringify  action.match
      updatedBid = merge state.bids[ index ], action.match

      state.bids = reject propEq( 'id', action.match.order_id ), state.bids

      state.bids.push updatedBid

      state.bid_ids = pluck 'id', state.bids

      saveBidToStorage updatedBid


      # console.log merge state.bids[ index ], action.match
      # saveBidToStorage merge state.bids[ index ], action.match



    # state.bids = reject propEq( 'id', action.match.order_id ), state.bids



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
          # console.log 'new run', JSON.stringify consolidateRun state.run, PRODUCT_ID


          saveRun state.run

        state.run = []


    if isEmpty state.run
      state.run = [ skinny action.match ]

      # console.log(
      #   parseFloat( ( skinny action.match ).price ),
      #   2.0 * parseFloat( state[ ( skinny action.match ).side ].d_price )
      # )

      bidPrice =
        parseFloat( ( skinny action.match ).price ) +
        2.0 * parseFloat( state[ ( skinny action.match ).side ].d_price )

      # console.log bidPrice

      bid = cleanUpTrade
        price: bidPrice
        side: action.match.side
        product_id: PRODUCT_ID
        size: (
          state["#{action.match.side}Amount"]
        )

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
      openBids = filter(
        ( bid )->
          isNil prop 'reason', bid
        ,
        state.bids
      )

      if gooderSeaState state.bids, state[ action.match.side ].bid
        makeNewBid(
          state[ action.match.side ].bid,
          pluck 'id', openBids
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

    # prices = pluck 'd_price', runs

    # extremes = [
    #   parseFloat( Math.min.apply( this, prices ).toFixed( 4 ) )
    #   parseFloat( Math.max.apply( this, prices ).toFixed( 4 ) )
    # ]

    response =
      d_time: averageOf( 'd_time' )( runs )
      d_price: parseFloat( ( averageOf( 'd_price' )( runs ) ).toFixed 4 )
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

{
  addRunToQueue
} = require './workers/saveRunToStorage'

saveRun = ( run )->
  consolidated = consolidateRun run, PRODUCT_ID

  new Promise ( resolve, rejectPromise )->
    addRunToQueue( consolidated )


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

productStream.subscribe "*", ( hi )->

  # console.log JSON.stringify hi

  if 'match' is hi.type
    store.dispatch
      type: 'ADD_MATCH'
      match: hi


  if 'done' is hi.type and 'canceled' is hi.reason
    # console.log hi
    store.dispatch
      type: 'BID_CANCELLED'
      bid: hi


  if 'done' is hi.type and 'filled' is hi.reason
    store.dispatch
      type: 'MATCH_FILLED'
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
    # 'bottom'
    'sell'
    # 'topValue'
    # 'top'
    'buy'
    # 'buyPrice'
    # 'runs'
    # 'tick'
    # 'run'
    # 'buyAmount'
    # 'sellAmount'
    # 'bids'
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

# store.subscribe _throttle updatedStore, 1 * 1000




pulse = ->
  store.dispatch
    type: 'HEARTBEAT'
setTimeout (->
  setInterval pulse, 60 * 1000
), 60 * 1000






































getRunsFromStorage = require './lib/getRunsFromStorage'
getFills = require './lib/getFills'
getBids = require './lib/getBids'


addRun = ( run, index = 1 )->
  storeDispatch = ->

    store.dispatch
      type: 'ADD_RUN'
      run: run

  setTimeout storeDispatch, index * 1000


sortByAbsSize = ( a, b )->
  Math.abs( prop 'd_price', b ) - Math.abs( prop 'd_price', a )



dispatchFill = ( fill )->
  store.dispatch
    type: 'ADD_FILL'
    fill: fill


adfdsafafdsa = ->

  promises = {
    fills: getFills( PRODUCT_ID ),
    bids: getBids( PRODUCT_ID, reason: 'filled' ),
    runs: getRunsFromStorage( product_id: PRODUCT_ID ),
    cancelAllOrders: gdax.cancelAllOrders [ PRODUCT_ID ]
  }

  RSVP.hash( promises ).then( ( good )->
    console.log good.fills.length, good.bids.length
    map dispatchFill, good.fills.concat good.bids
    addIndex( map ) addRun, sort sortByAbsSize, good.runs

    map(
      ( bid )->
        store.dispatch
          type: 'ADD_BID'
          bid: bid
      ,
      good.bids
    )

    start( PRODUCT_ID )

  ).catch( ( bad )->
    console.log 'bad'
  )

setTimeout adfdsafafdsa, ( process.env.DELAY * 1000 )


###
use candles to gauge where things are trending
###

inTheWind = require './lib/inTheWind'

# https://docs.gdax.com/#get-historic-rates
normaJean = ->
  gdax.stat(
    PRODUCT_ID
  ).then(
    inTheWind
  ).then(
    ( factors )->
      store.dispatch
        type: 'UPDATE_FACTORS'
        factors: factors

  ).catch(
    ( error )->
      console.log 'candles error', error
  )

setInterval(
  normaJean,
  60 * 1000
)
normaJean()






process.on 'SIGINT', ->
  gdax.cancelAllOrders [ PRODUCT_ID ]
  console.log 'graceful timeout', PRODUCT_ID

  timeout = ->
    gdax.cancelAllOrders [ PRODUCT_ID ]
    console.log 'graceful kill', PRODUCT_ID
    process.exit err ? 1 : 0

  setTimeout timeout, 1000
