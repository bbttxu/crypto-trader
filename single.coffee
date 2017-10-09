

PRODUCT_ID = 'BTC-USD'

SIZING = 10

log = require './lib/log'

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



asdf = ( fill )->
  # console.log 'asdf', fill

  value = fill.price * fill.size
  # console.log 'q'
  if fill.side is 'buy'
    # console.log value, fill
    value = -1.0 * value

  # console.log value
  value

progress = ( data )->
  # console.log 'progress', data

  a = map asdf, data

  # console.log 'a', a
{ createStore, applyMiddleware } = require 'redux'
thunk = require 'redux-thunk'

moment = require 'moment'

consolidateRun = require './consolidateRun'

averageOf = require './lib/averageOf'

reducer = (state, action) ->
  if typeof state == 'undefined'
    return initalState


  if 'UPDATE_TOP' is action.type
    state.top = action.data

    state.sellAmount = state.top.available / SIZING

  if 'UPDATE_BOTTOM' is action.type
    state.bottom = action.data

    if state.top and state.sell and state.sell

      state.buyAmount = state.bottom.available / state.sell.price / SIZING


  if 'ADD_RUN' is action.type
    console.log 'add _ run'
    # state.runs.push action.run

  if 'ADD_MATCH' is action.type
    # console.log 'ADD_MATCH', action.match


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


    unless isEmpty state.run

      sameSide = ( runners )->
        runners.side is action.match.side

      # if all pass
      # being the same side as action.match
      # then add it to the run
      # else
      #   move the latest run to the runs
      #   empty out the run field so that the next one who can do it

      importantValue = all sameSide, state.run

      if importantValue
        state.run.push skinny action.match


      unless importantValue

        # doit = consolidateRun state.run, PRODUCT_ID

        # console.log 'doit'

        # saveRun( state.run, PRODUCT_ID ).then ( run )->
        #   console.log 'saveRun sucess', run


        # Don't use runs that are only one fill long
        if state.run.length > 1
          state.runs.push consolidateRun state.run, PRODUCT_ID

        state.run = []


    if isEmpty state.run
      state.run = [ skinny action.match ]

      # console.log skinny action.match
      # console.log ( skinny action.match ).side
      # console.log state[ ( skinny action.match ).side ]

      # console.log
      bidPrice =
        parseFloat( ( skinny action.match ).price ) +
        2.0 * parseFloat( state[ ( skinny action.match ).side ].d_price )

      bid = cleanUpTrade
        price: bidPrice
        side: action.match.side
        product_id: PRODUCT_ID


      lkfafdijwe = state[ ( skinny action.match ).side ]

      iuwoiqe = merge lkfafdijwe, bid: bid


      if 'sell' is ( skinny action.match ).side
        state.sell = iuwoiqe

      else
        state.buy = iuwoiqe
      #   state[ ( skinny action.match ).side ],
      #   { bid: bid }



    action.match.timestamp = moment( action.match.time ).valueOf()

    if 'sell' is action.match.side
      keys = [
        'price'
        'sequence'
        'time'
        'timestamp'
      ]


      state.sell = merge state.sell, pick keys, action.match
      state.sellPrice = state.sell.price

    if 'buy' is action.match.side
      keys = [
        'price'
        'sequence'
        'time'
        'timestamp'
      ]


      state.buy = merge state.buy, pick keys, action.match
      state.buyPrice = state.buy.price


  if state.top and state.sell
    state.topValue = state.sell.price * state.top.available


  if state.bottom and state.buy
    state.buyPrice = state.bottom.available







    # console.log 'always!!!', all(equals(propEq('side', action.match.side)))(state.run), state.run.length



    # unless isEmpty state.run


    #   if all(equals(propEq('side', action.match.side)))(state.run)
    #     console.log 'state.run', state.run
    #     state.run.push action.match

    #   else
    #     console.log state.runs.length, 'else', pick ['size', 'price', 'trade_id', 'side'], action.match

    #     newRun = state.run
    #     console.log 'newRun', newRun
    #     state.runs.push newRun
    #     state.run = [ action.match ]
    # else
    #   console.log '-- make default', pick ['size', 'price', 'trade_id', 'side'], action.match
    #   state.run.push pick ['size', 'price', 'trade_id', 'side'], action.match





    # state.runs.push action.match


  if 'FILL_ADDED' is action.type
    state.fills.push action.fill

  # console.log state, 'z'
  # console.log state.fills.length, 'y'

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

saveRun = require('./saveRun')



###
  ___ ___ .__       .__              .____
 /   |   \|__| ____ |  |__           |    |    ______  _  __
/    ~    \  |/ ___\|  |  \   ______ |    |   /  _ \ \/ \/ /
\    Y    /  / /_/  >   Y  \ /_____/ |    |__(  <_> )     /
 \___|_  /|__\___  /|___|  /         |_______ \____/ \/\_/
       \/   /_____/      \/                  \/
###

RSVP = require 'rsvp'

{
  getAccounts
} = require './lib/gdax-client'

updateAccountTotals = ( product_id )->
  parts = product_id.split '-'

  topKey = parts[0]
  bottomKey = parts[1]


  matchCurrency = ( currency )->
    console.log 'matchCurrency', currency
    ( record )->
      currency is record.currency


  dispatchCurrency = ( currency )->
    ( record )->
      store.dispatch
        type: currency
        data: record


  new RSVP.Promise ( resolve, reject )->
    getAccounts( product_id ).then ( result )->
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
    console.log 'start onSuccess', result

  onError = ( error )->
    console.log 'start onError', error

  updateAccountTotals( product_id ).then( onSuccess ).catch( onError )






  # onSuccess = ( db )->
    # fills = db.collection 'fill'
    # matches = db.collection 'matches'



    # fills
    #   .find( { product_id: product_id } ).toArray (err,data)->
    #     if err
    #       console.log 'err', err
    #       reject err

    #     # console.log data

    #     mapDispatch = (fill)->
    #       store.dispatch
    #         type: 'FILL_ADDED'
    #         fill: fill

    #     map mapDispatch, data

    # matches
    #   .find( { product_id: product_id } )
    #   .limit( 5 )
    #   .sort(trade_id: 1)
    #   .toArray (err,data)->
    #     if err
    #       console.log 'err', err
    #       reject err

    #     # console.log data

    #     mapDispatch = (match)->
    #       # console.log match
    #       store.dispatch
    #         type: 'ADD_MATCH'
    #         match: match

    #     map mapDispatch, data



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
    'tick'
    # 'run'
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


store.subscribe _throttle updatedStore, 3000

start( PRODUCT_ID )

