R = require 'ramda'
redux = require 'redux'
moment = require 'moment'

saveFill = require '../lib/saveFill'
predictions = require '../lib/predictions'

projectionMinutes = 10
historicalMinutes = projectionMinutes * 3



universalBad = ( err )->
  console.log 'bad', err
  throw err if err


initalState =
  currencies: {}
  prices: {}
  predictions: {}
  matches: {}

  sent: []
  orders: []

reducers = (state, action) ->

  if typeof state == 'undefined'
    return initalState

  if action.type is 'UPDATE_ACCOUNT'
    state.currencies[action.currency.currency] = R.pick ['hold', 'balance'], action.currency

  if action.type is 'ORDER_SENT'
    # console.log 'ORDER_SENT', action.order
    state.sent.push action.order

  if action.type is 'ORDER_RECEIVED'
    client_oid = action.order.client_oid
    if client_oid
      index = R.findIndex(R.propEq('client_oid', client_oid))( state.sent)
      if index >= 0
        state.orders.push action.order
        state.sent.splice( index, 1 )


  if action.type is 'ORDER_FILLED'
    # console.log action.order
    client_oid = action.order.client_oid
    if client_oid
      index = R.findIndex(R.propEq('client_oid', client_oid))( state.orders )
      if index >= 0

        state.orders = state.orders.splice( index, 1 )

        getFills()

  if action.type is 'ORDER_CANCELLED'
    order_id = action.order.order_id
    console.log 'ORDER_CANCELLED', order_id
    if order_id
      index = R.findIndex(R.propEq('order_id', order_id))( state.orders )
      if index >= 0
        state.orders.splice( index, 1 )

  if action.type is 'ORDER_MATCHED'
    saveFillSuccess = ( result )->
      since = moment( result.created_at ).fromNow( true )
      if result is true
        console.log '$', since
      else
        console.log '+', since


    saveFill( action.match ).then( saveFillSuccess ).catch( universalBad )

    key = [ action.match.product_id, action.match.side ].join( '-' ).toUpperCase()

    state.prices[key] = R.pick [ 'time', 'price'], action.match

    unless state.matches[key]
      state.matches[key] = []

    state.matches[key].push action.match

    byTime = ( doc )->
      moment( doc.time ).valueOf()

    tooOld = ( doc )->
      cutoff = moment().subtract historicalMinutes, 'minute'
      moment( doc.time ).isBefore cutoff

    state.matches[key] = R.reject tooOld, R.sortBy byTime, state.matches[key]

    future = moment().add( projectionMinutes, 'minute' ).utc().unix()
    predictor = predictions action.match.side, future, key

    state.predictions[key] = predictor state.matches[key]

  state

module.exports = reducers
