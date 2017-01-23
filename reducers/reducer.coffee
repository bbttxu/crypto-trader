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
  heartbeat: 0
  currencies: {}
  prices: {}
  predictions: {}
  proposals: []
  matches: {}

  sent: []
  orders: []

initalState.matches = defaults config, []
initalState.predictions = defaults config, {}
initalState.proposals = defaults config, []


byTime = ( doc )->
  moment( doc.time ).valueOf()

tooOld = ( doc )->
  cutoff = moment().subtract historicalMinutes, config.default.interval.units
  moment( doc.time ).isBefore cutoff


reducers = (state, action) ->

  if typeof state == 'undefined'
    return initalState

  # heartbeat ensures that proposed orders, and active orders don't stagnate
  state.heartbeat = action.message if action.type is 'HEARTBEAT'


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
    side = pair.split('-')[2].toLowerCase()

    state.matches[pair] = R.reject tooOld, R.sortBy byTime, state.matches[pair]

    future = moment().add( projectionMinutes, config.default.interval.units ).utc().unix()

    # only make a prediction if we're interested in the outcome

    # if undefined isnt state.predictions[pair]
    predictor = predictions side, future, pair

    state.predictions[pair] = predictor state.matches[pair]


  R.map keepFresh, R.keys state.predictions

  predictionResults = R.values R.pick [ 'predictions' ], state

  state.proposals = proposals ( R.pick [ 'currencies' ], state ), predictionResults

  # console.log R.keys state
  # console.log moment().format(), JSON.stringify R.pick ['proposals'], state

  state

module.exports = reducers
