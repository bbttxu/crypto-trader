{
  findIndex
  lensPath
  pick
  propEq
  set
  view
} = require 'ramda'

redux = require 'redux'
moment = require 'moment'

pricing = require '../lib/pricing'
predictions = require '../lib/predictions'
# proposals = require '../lib/proposals'
cleanUpTrades = require '../lib/cleanUpTrades'
checkObsoleteTrade = require '../lib/checkObsoleteTrade'
positionDetermine = require '../lib/positionDetermine'
halfsies = require '../lib/halfsies'
handleFractionalSize = require '../lib/handleFractionalSize'
stategy = require '../lib/stategy'

log = require '../lib/log'

defaults = require '../defaults'

config = require '../config'

projectionMinutes = config.default.interval.value
historicalMinutes = projectionMinutes * 3


initalState =
  tick: 0
  # now: moment()
  # heartbeat: 0
  # currencies: {}
  prices: {}
  # predictions: {}
  # proposals: []


  matches: {}

  projections: {}


  # stats: {}
  # sent: []
  # orders: []
  # advice: {}
  # positions: {}

# initalState.predictions = defaults config, {}


# console.log initalState


# byTime = ( doc )->
#   moment( doc.time ).valueOf()

# tooOld = ( doc )->
#   # cutoff = moment().subtract historicalMinutes, config.default.interval.units

#   # FIXME hard-coded
#   cutoff = moment().subtract 24, 'hours'
#   moment( doc.time ).isBefore cutoff


# asdf = ( value, seconds )->
#   cutoff = moment().subtract value, seconds

#   beforeCutoff = ( doc )->
#     moment( doc.time ).isBefore cutoff

#   ( values )->
#     reject beforeCutoff, values


reducer = (state, action) ->

  if typeof state == 'undefined'
    return initalState

  state.tick = state.tick + 1

  # log action


  if action.type is 'PROJECTION_UPDATE'
    console.log 'PROJECTION_UPDATE', action.type, action.path, action.projection

    projectionLens = lensPath [ 'projection' ].concat action.path
    projectionView = view projectionLens, state

    if projectionView
      console.log 'a'
      state = set projectionLens, projectionView



    unless projectionView
      console.log 'b'
      product_id = action.path[0]
      side = action.path[1]
      interval = action.path[2]

      console.log 'c', product_id, side, interval

      # state = set projectionLens, projectionView

      # ensure projection
      unless state['projections'][product_id]
        state['projections'][product_id] = {}

        console.log 'd'

      unless state['projections'][product_id][side]
        state['projections'][product_id][side] = {}

      unless state['projections'][product_id][side][interval]
        state['projections'][product_id][side][interval] = [ action.projection ]




  if action.type is 'ADD_MATCH'
    # console.log action, 'ADD_ORDER'

    matchesLens = lensPath [
      'matches',
      action.product_id,
      action.side,
      action.interval
    ]

    matchesView = view matchesLens, state
    if matchesView
      state = set matchesLens, matchesView.concat( action.match ), state


    unless matchesView

      # ensure product
      unless state['matches'][action.product_id]
        state['matches'][action.product_id] = {}

      unless state['matches'][action.product_id][action.side]
        state['matches'][action.product_id][action.side] = {}

      unless state['matches'][action.product_id][action.side][action.interval]
        state['matches'][action.product_id][action.side][action.interval] = [ action.match ]




    priceLens = lensPath [ 'prices', action.product_id, action.side ]

    priceMatch = pick ['price', 'timestamp', 'sequence'], action.match

    pricesView = view priceLens, state
    if pricesView
      if priceMatch.sequence > pricesView.sequence and priceMatch.timestamp >= pricesView.timestamp

        # console.log pricesView
        # console.log priceMatch, 'cccdadfdafadsfasdfasdfasd'
        state = set priceLens, priceMatch, state


    unless pricesView

      # ensure product
      unless state['prices'][action.product_id]
        state['prices'][action.product_id] = {}

      unless state['prices'][action.product_id][action.side]
        state['prices'][action.product_id][action.side] = priceMatch



  if action.type is 'REMOVE_MATCH'
    lens = lensPath [ 'matches', action.product_id, action.side, action.interval ]
    removeView = view lens, state

    index = findIndex ( propEq 'sequence', action.match.sequence ), removeView

    if index >= 0
      state.matches[ action.product_id ][ action.side ][ action.interval ].splice( index, 1 )


  # if action.type is 'ORDER_MATCHED'

  #   lens = lensPath [ 'matches', action.product_id, action.side, action.interval ]

  #   view = view lens, state

  #   if view
  #     state = set lens, view.concat( action.match ), state

  #   unless view

  #     # ensure product
  #     unless state['matches'][action.product_id]
  #       state['matches'][action.product_id] = {}

  #     unless state['matches'][action.product_id][action.side]
  #       state['matches'][action.product_id][action.side] = {}

  #     unless state['matches'][action.product_id][action.side][action.interval]
  #       state['matches'][action.product_id][action.side][action.interval] = [ action.match ]


  # if action.type is 'UPDATE_PROJECTION'

  #   # console.log action, 'abc'

  #   path = [ 'projections', action.product_id, action.side, action.interval ]
  #   lens = lensPath path


  #   view = view lens, state

  #   if view
  #     state = set lens, action.projection, state

  #     console.log path, view lens, state


  #   unless view

  #     # ensure product
  #     unless state['projections'][action.product_id]
  #       state['projections'][action.product_id] = {}

  #     unless state['projections'][action.product_id][action.side]
  #       state['projections'][action.product_id][action.side] = {}

  #     unless state['projections'][action.product_id][action.side][action.interval]
  #       state['projections'][action.product_id][action.side][action.interval] = [ action.match ]


    # console.log 'aaa', state.matches
    # # Store local unix timestamp to model
    # action.match.local = state.now.valueOf()

    # key = [ action.match.product_id, action.match.side ].join( '-' ).toUpperCase()

    # latestPrice = state.prices[key]
    # thisPrice = pick [ 'trade_id', 'price'], action.match

    # unless latestPrice
    #   state.prices[key] = thisPrice

    # # Only update if trade_id is greater than current
    # if latestPrice and thisPrice.trade_id > latestPrice.trade_id

    #   state.prices[key] = thisPrice

    #   state.positions = positionDetermine state.currencies, state.prices

    # # Find any proposals that are no longer relevant
    # # e.g. price is out-of-date and would incur a fee
    # existingTradeCriteria = (foo)->
    #   action.match.side is foo.side and action.match.product_id is foo.product_id

    # index = findIndex(existingTradeCriteria)(state.proposals)

    # if index > 0
    #   if checkObsoleteTrade state.proposals[index], action.match.price
    #     state.proposals.splice index, 1

    # state.matches.push action.match

  # if action.type is 'UPDATE_ACCOUNT'
  #   state.currencies[action.currency.currency] = pick ['hold', 'balance'], action.currency

  #   state.positions = positionDetermine state.currencies, state.prices


  # if action.type is 'ORDER_SENT'
  #   currency = action.ordeproduct_id.split('-')[1]
  #   side = action.ordeside

  #   state.currencies[currency].hold = pricing.size( parseFloat( state.currencies[currency].hold ) + parseFloat( action.ordesize ) )
  #   state.currencies[currency].balance = pricing.size( parseFloat( state.currencies[currency].balance ) - parseFloat( action.ordesize ) )

  #   state.sent.push action.order

  # if action.type is 'ORDER_RECEIVED'
  #   client_oid = action.ordeclient_oid
  #   if client_oid
  #     index = findIndex(propEq('client_oid', client_oid))( state.sent)
  #     if index >= 0
  #       state.orders.push action.order
  #       state.sent.splice( index, 1 )


  # if action.type is 'ORDER_FILLED'
  #   order_id = action.ordeorder_id
  #   if order_id
  #     index = findIndex(propEq('order_id', order_id))( state.orders )
  #     if index >= 0
  #       state.orders.splice( index, 1 )


  # if action.type is 'ORDER_CANCELLED'
  #   order_id = action.ordeorder_id
  #   if order_id
  #     index = findIndex(propEq('order_id', order_id))( state.orders )
  #     if index >= 0

  #       currency = action.ordeproduct_id.split('-')[1]
  #       side = action.ordeside
  #       size = parseFloat action.ordesize

  #       if 'buy' is side
  #         size = -1 * size


  #       state.currencies[currency].hold = pricing.size( parseFloat( state.currencies[currency].hold ) - size )
  #       state.currencies[currency].balance = pricing.size( parseFloat( state.currencies[currency].balance ) + size )

  #       state.orders.splice( index, 1 )



  # updatePredictionsByCurrencySide = ( matches, key )->

  #   side = key.split( '-' )[2].toLowerCase()

  #   past = moment().subtract( 864, 'seconds' ).utc().unix()
  #   future = moment().add( 864, 'seconds' ).utc().unix()


  #   minutes = moment().subtract( 864, 'seconds' ).utc().unix()
  #   hours = moment().subtract( 8640, 'seconds' ).utc().unix()
  #   day = moment().subtract( 86400, 'seconds' ).utc().unix()

  #   byTimeFrame = ( doc )->
  #      docTime = moment( doc.time ).utc().unix()

  #      return 864 if docTime > minutes
  #      return 8640 if docTime < minutes and docTime > hours
  #      86400

  #   makePredictions = ( docs )->
  #     predictor = predictions side, future, key
  #     predictor docs

  #   map makePredictions, groupBy byTimeFrame, matches




  # updatePredictions = ( currencyIntents )->

  #   state.matches = sortBy prop( 'time' ), state.matches

  #   byProductAndSide = ( doc )->
  #     [ doc.product_id, doc.side ].join( '-' ).toUpperCase()


  #   grouped = groupBy byProductAndSide, state.matches

  #   foo = mapObjIndexed updatePredictionsByCurrencySide, grouped


  #   # In order to prevent us make proposals for currencies and sides we don't want
  #   # we winnow out those we're not interested in
  #   final = {}
  #   finalize = ( currencySidePair )->
  #     final[ currencySidePair ] = foo[ currencySidePair ]

  #   forEach finalize, currencyIntents

  #   final


  # hasProjection = ( doc )->
  #   doc.linear

  # proposalsToArray = ( proposal, key )->
  #   proposal.timeframe = key
  #   proposal


  # findBestProposal = ( proposals, currencySide )->
  #   side = currencySide.split( '-' )[2].toLowerCase()


  #   #
  #   # if undefined return
  #   return proposals unless proposals

  #   doable = values mapObjIndexed proposalsToArray, filter hasProjection, proposals

  #   ordered = sortBy prop( 'linear' ), doable

  #   if 'sell' is side
  #     ordered = reverse ordered

  #   head ordered


  # makeTradeProposal = ( doc, key )->

  #   parts = key.split '-'

  #   if doc
  #     doc.side = parts[2].toLowerCase()
  #     doc.product_id = [ parts[0], parts[1] ].join '-'
  #     doc.price = doc.linear

  #     doc.size = halfsies doc.current, doc.linear, state.currencies[ parts[0] ].balance


  #   doc

  # # heartbeat ensures that proposed orders, and active orders don't stagnate
  # if action.type is 'HEARTBEAT'
  #   state.heartbeat = action.message


  #   start = moment().valueOf()


  #   asdfasdf = ( a, b )->
  #     asdfasdfasdf = ( c )->
  #       [ b, c ].join( '-' ).toUpperCase()

  #     map asdfasdfasdf, keys a


  #   state.predictions = updatePredictions uniq flatten values mapObjIndexed asdfasdf, state.advice

  #   bestPredictions = reject isNil, values mapObjIndexed makeTradeProposal, mapObjIndexed findBestProposal, state.predictions



  #   #
  #   #
  #   fdsa = ( doc )->
  #     handleFractionalSize doc, 0.01

  #   dontOverextend = filter fdsa, bestPredictions


  #   #
  #   # TODO could roll into cleanUpTrades??
  #   ensureMinimumSize = ( doc )->
  #     if doc.size < 0.01
  #       doc.size = 0.01

  #     doc


  #   validBids = map ensureMinimumSize, dontOverextend

  #   state.proposals = map cleanUpTrades, validBids

  #   console.log 'HEARTBEAT', ( moment().valueOf() - start ), 'ms'

  # return
  state

module.exports = reducer
