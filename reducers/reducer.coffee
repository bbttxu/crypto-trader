R = require 'ramda'
redux = require 'redux'
moment = require 'moment'

pricing = require '../lib/pricing'
predictions = require '../lib/predictions'
proposals = require '../lib/proposals'
defaults = require '../defaults'

config = require '../config'

projectionMinutes = config.default.interval.value
historicalMinutes = projectionMinutes * 3


initalState =
  now: moment()
  heartbeat: 0
  currencies: {}
  prices: {}
  predictions: {}
  proposals: []
  matches: {}
  stats: {}
  sent: []
  orders: []

initalState.matches = defaults config, []
initalState.predictions = defaults config, {}
initalState.proposals = defaults config, []


byTime = ( doc )->
  moment( doc.time ).valueOf()

tooOld = ( doc )->
  # cutoff = moment().subtract historicalMinutes, config.default.interval.units

  # FIXME hard-coded
  cutoff = moment().subtract 24, 'hours'
  moment( doc.time ).isBefore cutoff


asdf = ( value, seconds )->
  cutoff = moment().subtract value, seconds

  beforeCutoff = ( doc )->
    moment( doc.time ).isBefore cutoff

  ( values )->
    R.reject beforeCutoff, values


reducers = (state, action) ->

  if typeof state == 'undefined'
    return initalState

  state.now = moment()

  # heartbeat ensures that proposed orders, and active orders don't stagnate
  state.heartbeat = action.message if action.type is 'HEARTBEAT'

  # Record Stats
  if action.type is 'UPDATE_STATS'
    state.stats = action.stats

  if action.type is 'UPDATE_ACCOUNT'
    state.currencies[action.currency.currency] = R.pick ['hold', 'balance'], action.currency

  if action.type is 'ORDER_SENT'
    currency = action.order.product_id.split('-')[1]
    side = action.order.side
    # size = parseFloat action.order.size

    # console.log currency, side, size

    # if 'buy' is side
    #   size = -1 * size

    state.currencies[currency].hold = pricing.size( parseFloat( state.currencies[currency].hold ) + parseFloat( action.order.size ) )
    state.currencies[currency].balance = pricing.size( parseFloat( state.currencies[currency].balance ) - parseFloat( action.order.size ) )

    state.sent.push action.order

  if action.type is 'ORDER_RECEIVED'
    client_oid = action.order.client_oid
    if client_oid
      index = R.findIndex(R.propEq('client_oid', client_oid))( state.sent)
      if index >= 0
        state.orders.push action.order
        state.sent.splice( index, 1 )


  if action.type is 'ORDER_FILLED'
    order_id = action.order.order_id
    if order_id
      index = R.findIndex(R.propEq('order_id', order_id))( state.orders )
      if index >= 0
        state.orders.splice( index, 1 )


  if action.type is 'ORDER_CANCELLED'
    order_id = action.order.order_id
    if order_id
      index = R.findIndex(R.propEq('order_id', order_id))( state.orders )
      if index >= 0

        currency = action.order.product_id.split('-')[1]
        side = action.order.side
        size = parseFloat action.order.size

        if 'buy' is side
          size = -1 * size


        state.currencies[currency].hold = pricing.size( parseFloat( state.currencies[currency].hold ) - size )
        state.currencies[currency].balance = pricing.size( parseFloat( state.currencies[currency].balance ) + size )

        state.orders.splice( index, 1 )

  if action.type is 'ORDER_MATCHED'

    # Store local unix timestamp to model
    action.match.local = state.now.valueOf()

    key = [ action.match.product_id, action.match.side ].join( '-' ).toUpperCase()

    state.prices[key] = R.pick [ 'time', 'price'], action.match

    console.log moment().format(), ( R.values R.pick ['product_id', 'price', 'side', 'size'], action.match ).join ' '

    unless state.matches[key]
      state.matches[key] = []

    state.matches[key].push action.match


  # Ensure that for all currency pairs
  # 1. remove out-of-window trades
  # 2. new predictions
  keepFresh = (pair)->
    # console.log 'pear', pair
    side = pair.split('-')[2].toLowerCase()

    state.matches[pair] = R.reject tooOld, R.sortBy byTime, state.matches[pair]


    now = moment().utc()
    cutoff0 = now.subtract 86400, 'seconds'
    cutoff1 = now.subtract 8640, 'seconds'
    cutoff2 = state.now.subtract( 864, 'seconds' ).valueOf()


    reject0 = ( doc )->
      moment( doc.time ).isBefore cutoff0

    reject1 = ( doc )->
      moment( doc.time ).isBefore cutoff1

    reject2 = ( doc )->
      # console.log doc.local, cutoff2, ( doc.local - cutoff2 )
      moment( doc.time ).isBefore cutoff2


    allStateMatchesPair = R.reject reject0, state.matches[pair]
    allStateMatchesPair1 = R.reject reject1, state.matches[pair]
    allStateMatchesPair2 = R.reject reject2, state.matches[pair]


    # console.log 'abc'
    # # console.log state.matches[pair]
    # console.log allStateMatchesPair.length
    # console.log allStateMatchesPair1.length
    # console.log allStateMatchesPair2.length
    # console.log 'def'




    future = moment().add( 864, 'seconds' ).utc().unix()
    future1 = moment().add( 8640, 'seconds' ).utc().unix()
    future2 = moment().add( 86400, 'seconds' ).utc().unix()

    # only make a prediction if we're interested in the outcome

    # if undefined isnt state.predictions[pair]
    predictor = predictions side, future, pair
    predictor1 = predictions side, future1, pair
    predictor2 = predictions side, future2, pair

    guesses = [
      predictor allStateMatchesPair
      predictor1 allStateMatchesPair1
      predictor2 allStateMatchesPair2
    ]

    # console.log 'guesses', pair, guesses

    noGuess = ( data )->
      not data.linear

    guesses = R.reject noGuess, guesses

    # console.log 'guesses', pair, guesses

    getBestGuess = ( a )->
      a.linear


    if guesses.length > 0

      discriminator = R.head

      if side is 'sell'
        discriminator = R.last

      sortedGuesses = R.sortBy getBestGuess, guesses

      theGuess = discriminator sortedGuesses

      # console.log 'best guess is ', pair, side, theGuess

      state.predictions[pair] = theGuess


  R.map keepFresh, R.keys state.predictions

  predictionResults = R.values R.pick [ 'predictions' ], state

  state.proposals = proposals ( R.pick [ 'currencies' ], state ), predictionResults

  # console.log R.keys state
  # console.log moment().format(), JSON.stringify R.pick ['proposals'], state

  state

module.exports = reducers
