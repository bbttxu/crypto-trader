R = require 'ramda'
redux = require 'redux'
moment = require 'moment'

pricing = require '../lib/pricing'
predictions = require '../lib/predictions'
proposals = require '../lib/proposals'

config = require '../config'

projectionMinutes = config.default.interval.value
historicalMinutes = projectionMinutes * 3


initalState =
  currencies: {}
  prices: {}
  predictions: {}
  proposals: []
  matches: {}

  sent: []
  orders: []

reducers = (state, action) ->

  if typeof state == 'undefined'
    return initalState

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

    byTime = ( doc )->
      moment( doc.time ).valueOf()

    tooOld = ( doc )->
      cutoff = moment().subtract historicalMinutes, config.default.interval.units
      moment( doc.time ).isBefore cutoff

    # TODO this should be run each time the state is updated, not only for matches
    state.matches[key] = R.reject tooOld, R.sortBy byTime, state.matches[key]

    future = moment().add( projectionMinutes, config.default.interval.units ).utc().unix()
    predictor = predictions action.match.side, future, key

    state.predictions[key] = predictor state.matches[key]

  predictionResults = R.values R.pick [ 'predictions' ], state

  state.proposals = proposals ( R.pick [ 'currencies' ], state ), predictionResults

  state

module.exports = reducers
