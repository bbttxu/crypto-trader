require( 'dotenv' ).config( silent: true )
argv = require('minimist')(process.argv.slice(2))
PRODUCT_ID = process.env.PRODUCT_ID ||  argv._[0]
DELAY = process.env.DELAY || 3

unless PRODUCT_ID
  log 'need a product id!'

# SIZING = 60


kue = require 'kue'

queue = kue.createQueue()

RSVP = require 'rsvp'

log = require './lib/log'

# handleFractionalSize = require './lib/handleFractionalSize'

gdax = require './lib/gdax-client'

assessBids = require './lib/assessBids'
assessPrices = require './lib/assessPrices'

# getDirection = require './lib/getDirection'
coveredBids = require './lib/coveredBids'
coveredPrice = require './lib/coveredPrice'

require('dotenv').config( silent: true )
mongoConnection = require('./lib/mongoConnection')

cleanUpTrade = require './lib/cleanUpTrades'

otherSide = require './lib/otherSide'
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
  takeLast
} = require 'ramda'



initalState =
  tick: 0
  direction: ''
  advice: [ 'hold' ]
  fills: []
  ratio: 0
  progress: 0
  top:
    available: 0
    hold: 0
    balance: 0

  bottom:
    available: 0
    hold: 0
    balance: 0
  run: []
  runs: []
  sell: {}
  buy: {}
  bid: {}
  counterBid: {}
  bids: []
  bid_ids: []
  persisted_ids: []
  match: {}
  # sellFactor: 0
  # buyFactor: 0
  stats: {}
  buyAmount: 0
  sellAmount: 0

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

addBid = ( bid )->
  # TODO make an optional flag so we can listen and record, but not trade
  # console.log bid
  # return 1

  onGood = ( foo )->
    message = foo.body

    if message.message
      log 'message.message', message.message

    else
      store.dispatch
        type: 'ADD_BID'
        bid: merge( JSON.parse( foo.body ), bid )


  onError = ( err )->
    log 'bid.side', bid.side, 'onError'
    log 'error', err, err.body

  # log 'start', bid.side, 'bid', bid

  gdax[ bid.side ](
    bid
  ).then(
    onGood
  ).catch(
    onError
  )



gooderSeaState = require './lib/gooderSeaState'
# dailyTide = require './lib/dailyTide'


sortByCreatedAt = sortBy prop( 'time' )

onlyFilledReasons = filter propEq( 'reason', 'filled' )

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

consolidateRun = require './lib/consolidateRun'

averageOf = require './lib/averageOf'

makeNewBid = ( bid, cancelPlease = [], label = false )->

  if false isnt label
    bid.reason = label

  addBid bid


  makeCancellation = ( cancelThisID )->
    # for hashes
    obj = {}
    obj[ cancelThisID ] = gdax.cancelOrder( cancelThisID )
    obj



  # since we're catching cancellations on the stream, we
  # don't really care of the outcome
  RSVP.hashSettled( mergeAll map makeCancellation, reject isNil, cancelPlease ).then( ( good )->


    #
    isFullfilled = ( outcome )->
      true is outcome.value

    fulfilled = filter isFullfilled, good


  ).catch( (error)->
    log 'really bad thing', error
  )


reducer = (state, action) ->

  ###
                  __                                       __                 ___.   .__    .___
    _____ _____  |  | __ ____     ____  ____  __ __  _____/  |_  ___________  \_ |__ |__| __| _/
  /     \\__  \ |  |/ // __ \  _/ ___\/  _ \|  |  \/    \   __\/ __ \_  __ \  | __ \|  |/ __ |
  |  Y Y  \/ __ \|    <\  ___/  \  \__(  <_> )  |  /   |  \  | \  ___/|  | \/  | \_\ \  / /_/ |
  |__|_|  (____  /__|_ \\___  >  \___  >____/|____/|___|  /__|  \___  >__|     |___  /__\____ |
        \/     \/     \/    \/       \/                 \/          \/             \/        \/
  ###

  makeCounterBid = ( match )->
    lastStreak = coveredBids( sortByCreatedAt( onlyFilledReasons( state.bids ) ), match.side )

    unless isEmpty lastStreak
      if lastStreak.length > 1

        price = coveredPrice lastStreak

        if price
          counterBid = cleanUpTrade
            price: price
            size: sum pluck 'size', lastStreak
            side: otherSide match.side
            product_id: PRODUCT_ID

          importantValues = pick [ 'price', 'size', 'side', 'product_id' ]

          log lastStreak.length, counterBid

          counterBids = filter propEq( 'reason', 'counter' ), state.bids

          unless equals importantValues( state.counterBid ), importantValues( counterBid )
            makeNewBid counterBid, pluck( 'id', counterBids ), 'counter'
            state.counterBid = counterBid



  if typeof state == 'undefined'
    return initalState


  if 'HEARTBEAT' is action.type
    start = Date.now()

    # do stuff here vvv


    log PRODUCT_ID, 'is in', ( state.advice || [] ).join( ", " ), 'mode'

    state.fills = sortBy prop( 'trade_id' ), state.fills
    log 'showStatus', showStatus state.fills

    overADayOld = ( run )->
      moment().subtract( 1, 'day' ).valueOf() > run.end

    state.runs = sortBy prop( 'start' ), reject overADayOld, state.runs

    overADayOldBids = ( bid )->
      moment().subtract( 7, 'days' ) > moment( bid.time )

    state.bids = reject overADayOldBids, state.bids

    state.bids = sortByCreatedAt( state.bids )

    pricesForSides = assessBids state.bids

    # console.log pricesForSides

    sidesPricing = assessPrices pricesForSides

    if not isEmpty sidesPricing
      # console.log sidesPricing
      console.log "SHOULD SELL ABOVE #{sidesPricing.sell || 'idk'}"
      console.log "SHOULD  BUY BELOW #{sidesPricing.buy || 'idk'}"



    # do stuff here ^^^

    log uniq pluck 'message', state.bids

    log moment( start ).format(),'HEARTBEAT', Date.now() - start, 'ms'


  if 'UPDATE_ADVICE' is action.type
    if not equals state.advice, action.advice
      state.advice = action.advice
      console.log 'ADVICE UPDATED to', state.advice.join ", "

  if 'UPDATE_STATS' is action.type
    state.stats = action.stats
    # state.direction = getDirection action.stats, state.direction

  # if 'UPDATE_FACTORS' is action.type
  #   state.sellFactor = action.factors.sellFactor
  #   state.buyFactor = action.factors.buyFactor


  if 'UPDATE_TOP' is action.type
    state.top = action.data
    # topAvailable = state.top.available || 0
    # state.sellAmount = ( topAvailable / SIZING ) * state.sellFactor


  if 'UPDATE_BOTTOM' is action.type
    state.bottom = action.data
    # bottomAvailable = state.bottom.available || 0
    # state.buyAmount = ( bottomAvailable / state.sell.price / SIZING ) * parseFloat( state.buyFactor )




  if 'ADD_BID' is action.type
    bid = pick(
      [
        'id',
        'product_id',
        'price',
        'size',
        'side',
        'reason'
      ],
      action.bid
    )

    # TODO why make bid variable above?
    persist = 'persist' is bid.reason or false

    state.bids.push action.bid

    if true is persist
      state.persisted_ids.push bid.id
    else
      state.bid_ids.push bid.id



  if 'ADD_RUN' is action.type
    unless 0 is action.run.d_price or 0 is action.run.d_time
      # log 'ADD_RUN', state.runs.length, moment( action.run.end ).fromNow()
      state.runs.push action.run


  if 'ADD_FILL' is action.type
    state.fills.push action.fill


  if 'BID_CANCELLED' is action.type

    index = findIndex propEq( 'id', action.bid.order_id ), state.bids

    if index > -1
      # log 'BID_CANCELLED', action.bid.order_id, action.bid
      updatedBid = merge state.bids[ index ], action.bid

      state.bids = reject propEq( 'id', action.bid.order_id ), state.bids

      state.bids.push updatedBid

      saveBidToStorage updatedBid


    idIndex = findIndex equals( action.bid.order_id ), state.bid_ids

    if idIndex > -1
      state.bid_ids = reject equals( action.bid.order_id ), state.bid_ids


    persistedIndex = findIndex equals( action.bid.order_id ), state.persisted_ids

    if persistedIndex > -1
      state.persisted_ids = reject equals( action.bid.order_id ), state.persisted_ids


  if 'MATCH_FILLED' is action.type

    index = findIndex propEq( 'id', action.match.order_id ), state.bids

    if index > -1
      log 'MATCH_FILLED', JSON.stringify  action.match
      updatedBid = merge state.bids[ index ], action.match

      state.bids = reject propEq( 'id', action.match.order_id ), state.bids

      state.bids.push updatedBid

      if contains action.match.side, state.advice
        makeCounterBid( action.match )


      saveBidToStorage updatedBid




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
          # log 'new run', JSON.stringify consolidateRun state.run, PRODUCT_ID


          saveRun state.run

        state.run = []


    if isEmpty state.run
      state.run = [ skinny action.match ]

      if contains action.match.side, state.advice
        makeCounterBid( action.match )


      if contains action.match.side, state.advice
        log "following #{action.match.side} advice of #{state.advice.join(', ')}"


        bidPrice =
          parseFloat( ( skinny action.match ).price ) +
          2.0 * parseFloat( state[ ( skinny action.match ).side ].d_price or 1 )


        bid = cleanUpTrade
          price: bidPrice
          side: action.match.side
          product_id: PRODUCT_ID
          size: 0.1
          stats: state.stats

        lkfafdijwe = state[ action.match.side ]

        iuwoiqe = merge lkfafdijwe, bid: bid

        if 'sell' is action.match.side
          state.sell = iuwoiqe

        if 'buy' is action.match.side
          state.buy = iuwoiqe


        log JSON.stringify state.bid, 'state.bid'


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

          # good24HourTrend = dailyTide( state.stats, state[ action.match.side ].bid )

          # if good24HourTrend
          if gooderSeaState( state.bids, state[ action.match.side ].bid )
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


Redis = require 'ioredis'
feedChannel = new Redis()

feedChannel.subscribe "feed:#{PRODUCT_ID}"

feedChannel.on 'message', ( channel, hi )->
  hi = JSON.parse hi

  if 'match' is hi.type
    store.dispatch
      type: 'ADD_MATCH'
      match: hi


  if 'done' is hi.type and 'canceled' is hi.reason
    store.dispatch
      type: 'BID_CANCELLED'
      bid: hi


  if 'done' is hi.type and 'filled' is hi.reason
    store.dispatch
      type: 'MATCH_FILLED'
      match: hi



###
            .___     .__
_____     __| _/__  _|__| ____  ____
\__  \   / __ |\  \/ /  |/ ___\/ __ \
 / __ \_/ /_/ | \   /|  \  \__\  ___/
(____  /\____ |  \_/ |__|\___  >___  >
     \/      \/              \/    \/
###


adviceChannel = new Redis()

adviceChannel.subscribe "advice:#{PRODUCT_ID}"

adviceChannel.on 'message', ( channel, jsonString )->
  store.dispatch
    type: 'UPDATE_ADVICE'
    advice: JSON.parse jsonString


parts = PRODUCT_ID.split '-'

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


###
       .__                  ___.
  ____ |  |__ _____    _____\_ |__   ___________
_/ ___\|  |  \\__  \  /     \| __ \_/ __ \_  __ \
\  \___|   Y  \/ __ \|  Y Y  \ \_\ \  ___/|  | \/
 \___  >___|  (____  /__|_|  /___  /\___  >__|
     \/     \/     \/      \/    \/     \/
chamber
###

chamberChannel = new Redis()

chamberChannel.subscribe "chamber:#{PRODUCT_ID}"

chamberChannel.on 'message', ( channel, jsonString )->
  bid = JSON.parse jsonString
  makeNewBid bid, [], 'persist'





accountChannel = new Redis()

accountChannel.subscribe "accounts"

accountChannel.on 'message', ( channel, jsonString )->
  accounts = JSON.parse jsonString

  dispatchCurrency( 'UPDATE_TOP' ) head filter matchCurrency( topKey ), accounts
  dispatchCurrency( 'UPDATE_BOTTOM' ) head filter matchCurrency( bottomKey ), accounts



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
    log good.fills.length, good.bids.length
    map dispatchFill, good.bids
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
    log 'bad'
  )

setTimeout adfdsafafdsa, ( process.env.DELAY * 1000 )


###
use candles to gauge where things are trending
###

# candleChannel = new Redis()

# candleChannel.subscribe "factors:#{PRODUCT_ID}"

# candleChannel.on 'message', ( channel, factors )->
#   store.dispatch
#     type: 'UPDATE_FACTORS'
#     factors: JSON.parse factors


###
            .___  .___           __          __             __           ___.   .__    .___
_____     __| _/__| _/   _______/  |______ _/  |_  ______ _/  |_  ____   \_ |__ |__| __| _/______
\__  \   / __ |/ __ |   /  ___/\   __\__  \\   __\/  ___/ \   __\/  _ \   | __ \|  |/ __ |/  ___/
 / __ \_/ /_/ / /_/ |   \___ \  |  |  / __ \|  |  \___ \   |  | (  <_> )  | \_\ \  / /_/ |\___ \
(____  /\____ \____ |  /____  > |__| (____  /__| /____  >  |__|  \____/   |___  /__\____ /____  >
     \/      \/    \/       \/            \/          \/                      \/        \/    \/
###

statsChannel = new Redis()

statsChannel.subscribe "stats:#{PRODUCT_ID}"

statsChannel.on 'message', ( channel, stats )->
  store.dispatch
    type: 'UPDATE_STATS'
    stats: JSON.parse stats




process.on 'SIGINT', ->
  gdax.cancelAllOrders [ PRODUCT_ID ]
  log 'graceful timeout', PRODUCT_ID

  timeout = ->
    gdax.cancelAllOrders [ PRODUCT_ID ]
    log 'graceful kill', PRODUCT_ID
    process.exit err ? 1 : 0

  setTimeout timeout, 1000
