R = require 'ramda'
redux = require 'redux'
moment = require 'moment'

pricing = require '../lib/pricing'
predictions = require '../lib/predictions'
proposals = require '../lib/proposals'
cleanUpTrades = require '../lib/cleanUpTrades'
checkObsoleteTrade = require '../lib/checkObsoleteTrade'

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
  matches: []
  stats: {}
  sent: []
  orders: []
  positions: {}

# initalState.matches = defaults config, []
initalState.predictions = defaults config, {}
# initalState.proposals = defaults config, []

console.log initalState


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

  # Record Stats
  if action.type is 'UPDATE_STATS'
    state.stats = action.stats

  if action.type is 'ORDER_MATCHED'

    # Store local unix timestamp to model
    action.match.local = state.now.valueOf()

    key = [ action.match.product_id, action.match.side ].join( '-' ).toUpperCase()

    state.prices[key] = R.pick [ 'time', 'price'], action.match


    # Find any proposals that are no longer relevant
    # e.g. price is out-of-date and would incur a fee
    existingTradeCriteria = (foo)->
      action.match.side is foo.side and action.match.product_id is foo.product_id

    index = R.findIndex(existingTradeCriteria)(state.proposals)

    if index > 0
      if checkObsoleteTrade state.proposals[index], action.match.price
        state.proposals.splice index, 1

    state.matches.push action.match

  if action.type is 'UPDATE_ACCOUNT'
    state.currencies[action.currency.currency] = R.pick ['hold', 'balance'], action.currency

    if state.currencies['BTC']
      console.log state.currencies.BTC

      state.positions['BTC'] = ( parseFloat(state.currencies['BTC'].balance) + parseFloat(state.currencies['BTC'].hold) ) # * parseFloat( state.prices['BTC-USD-SELL'].price)
      state.positions['BTC-price'] = state.stats['BTC-USD']

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


  # updateCurrencyIntents = ( asdfasdf )->
  #   console.log 'updateCurrencyIntents', state.matches.length, asdfasdf


  updatePredictionsByCurrencySide = ( matches, key )->

    side = key.split( '-' )[2].toLowerCase()

    past = moment().subtract( 864, 'seconds' ).utc().unix()
    future = moment().add( 864, 'seconds' ).utc().unix()


    minutes = moment().subtract( 864, 'seconds' ).utc().unix()
    hours = moment().subtract( 8640, 'seconds' ).utc().unix()
    day = moment().subtract( 86400, 'seconds' ).utc().unix()

    byTimeFrame = ( doc )->
       docTime = moment( doc.time ).utc().unix()

       return 864 if docTime > minutes
       return 8640 if docTime < minutes and docTime > hours
       86400

    makePredictions = ( docs )->
      predictor = predictions side, future, key
      predictor docs

    R.map makePredictions, R.groupBy byTimeFrame, matches




  updatePredictions = ( currencyIntents )->
    # console.log 'updatePredictions', currencyIntents

    state.matches = R.sortBy R.prop( 'time' ), state.matches

    byProductAndSide = ( doc )->
      [ doc.product_id, doc.side ].join( '-' ).toUpperCase()


    grouped = R.groupBy byProductAndSide, state.matches

    foo = R.mapObjIndexed updatePredictionsByCurrencySide, grouped


    # In order to prevent us make proposals for currencies and sides we don't want
    # we winnow out those we're not interested in
    final = {}
    finalize = ( currencySidePair )->
      final[ currencySidePair ] = foo[ currencySidePair ]

    R.forEach finalize, currencyIntents

    final


  hasProjection = ( doc )->
    doc.linear

  proposalsToArray = ( proposal, key )->
    proposal.timeframe = key
    proposal


  findBestProposal = ( proposals, currencySide )->
    side = currencySide.split( '-' )[2].toLowerCase()
    # console.log side, proposals


    doable = R.values R.mapObjIndexed proposalsToArray, R.filter hasProjection, proposals

    # console.log 'doable', doable

    ordered = R.sortBy R.prop( 'linear' ), doable

    # console.log 'ordered', ordered

    if 'sell' is side
      ordered = R.reverse ordered

    # console.log 'do it', R.head ordered

    R.head ordered


  makeTradeProposal = ( doc, key )->
    # console.log 'makeTradeProposal'

    parts = key.split '-'

    if doc
      doc.side = parts[2].toLowerCase()
      doc.product_id = [ parts[0], parts[1] ].join '-'
      doc.size = 0.01
      doc.price = doc.linear

      # console.log doc

    doc

  # heartbeat ensures that proposed orders, and active orders don't stagnate
  if action.type is 'HEARTBEAT'
    state.heartbeat = action.message
    console.log 'HEARTBEAT'

    start = moment()

    state.predictions = updatePredictions R.keys state.predictions

    state.proposals = R.map cleanUpTrades, R.reject R.isNil, R.values R.mapObjIndexed makeTradeProposal, R.mapObjIndexed findBestProposal, state.predictions

    # console.log state.proposals

    # console.log state.currencies

    # predictionResults = R.values R.pick [ 'predictions' ], state

    # console.log R.map cleanUpTrades, R.reject R.isNil, R.values R.mapObjIndexed makeTradeProposal, state.proposals


    console.log 'started predictions', start.fromNow()

    # R.map keepFresh, R.keys state.predictions


  # R.map keepFresh, R.keys state.predictions

  # predictionResults = R.values R.pick [ 'predictions' ], state

  # state.proposals = proposals ( R.pick [ 'currencies' ], state ), predictionResults

  # console.log R.keys state
  # console.log moment().format(), JSON.stringify R.pick ['proposals'], state

  state

module.exports = reducers
