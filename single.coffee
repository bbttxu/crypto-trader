

PRODUCT_ID = 'BTC-USD'

SIZING = 10

log = require './lib/log'

require('dotenv').config( silent: true )
mongoConnection = require('./lib/mongoConnection')

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

  if 'ADD_MATCH' is action.type
    console.log 'ADD_MATCH', action.match


    skinny = ( data )->
      pick [ 'side', 'size', 'price', 'sequence', 'time' ], data


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
        state.runs.push state.run
        state.run = []


    if isEmpty state.run
      state.run = [ skinny action.match ]




    if 'sell' is action.match.side
      keys = [
        'price'
        'sequence'
        'time'
      ]


      state.sell = pick keys, action.match
      state.sellPrice = state.sell.price



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


  state.tick = 1 + state.tick
  state



{ createStore, applyMiddleware } = require 'redux'
thunk = require 'redux-thunk'



store = createStore reducer, applyMiddleware(thunk.default)


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

  console.log parts, 'zz'

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
    console.log result

  onError = ( error )->
    console.log error

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
updatedStore = ->
  state = store.getState()
  importantKeys = [
    'tick'
    'progress'
    'volume'
    'ratio'
    'run'
    'bottom'
    'sell'
    'topValue'
    'top'
    'buy'
    'buyPrice'
    # 'runs'
  ]
  # importantKeys = [ 'tick', 'prices', 'matches' ]
  # importantKeys = [ 'tick', 'prices', 'projections' ]
  important = pick importantKeys, state

  # console.log moment().format(), 'we got this', '$',


  # log keys state
  log state

  # important.positions.total.totalUSD.toFixed( 2 )
  # log important
  console.log state.run.length, 'shrug :/'

store.subscribe _throttle updatedStore, 1000

start( PRODUCT_ID )

