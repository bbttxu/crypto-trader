# R = require 'ramda'
# redux = require 'redux'
# moment = require 'moment'

# pricing = require '../lib/pricing'
# predictions = require '../lib/predictions'
# # proposals = require '../lib/proposals'
# cleanUpTrades = require '../lib/cleanUpTrades'
# checkObsoleteTrade = require '../lib/checkObsoleteTrade'
# positionDetermine = require '../lib/positionDetermine'
# halfsies = require '../lib/halfsies'
# handleFractionalSize = require '../lib/handleFractionalSize'
# stategy = require '../lib/stategy'


# defaults = require '../defaults'

# config = require '../config'

# projectionMinutes = config.default.interval.value
# historicalMinutes = projectionMinutes * 3


# initalState =
#   now: moment()
#   heartbeat: 0
#   currencies: {}
#   prices: {}
#   predictions: {}
#   proposals: []

#   # store recent matches by interval
#   matches: {}

#   projections: {}


#   stats: {}
#   sent: []
#   orders: []
#   advice: {}
#   positions: {}

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
#     R.reject beforeCutoff, values


# reducers = (state, action) ->

#   if typeof state == 'undefined'
#     return initalState

#   state.now = moment()

#   # Record Stats
#   if action.type is 'UPDATE_STATS'
#     state.stats = action.stats
#     state.advice = stategy action.stats


#   if action.type is 'ADD_MATCH'
#     # console.log action, 'ADD_ORDER'


#     lens = R.lensPath [ 'matches', action.product_id, action.side, action.interval ]


#     view = R.view lens, state

#     if view
#       state = R.set lens, view.concat( action.match ), state


#     unless view

#       # ensure product
#       unless state['matches'][action.product_id]
#         state['matches'][action.product_id] = {}

#       unless state['matches'][action.product_id][action.side]
#         state['matches'][action.product_id][action.side] = {}

#       unless state['matches'][action.product_id][action.side][action.interval]
#         state['matches'][action.product_id][action.side][action.interval] = [ action.match ]


#   if action.type is 'REMOVE_MATCH'
#     lens = R.lensPath [ 'matches', action.product_id, action.side, action.interval ]
#     view = R.view lens, state

#     index = R.findIndex ( R.propEq 'sequence', action.match.sequence ), view

#     if index >= 0
#       state.matches[ action.product_id ][ action.side ][ action.interval ].splice( index, 1 )


#   if action.type is 'ORDER_MATCHED'


#     lens = R.lensPath [ 'matches', action.product_id, action.side, action.interval ]


#     view = R.view lens, state

#     if view
#       state = R.set lens, view.concat( action.match ), state

#     unless view

#       # ensure product
#       unless state['matches'][action.product_id]
#         state['matches'][action.product_id] = {}

#       unless state['matches'][action.product_id][action.side]
#         state['matches'][action.product_id][action.side] = {}

#       unless state['matches'][action.product_id][action.side][action.interval]
#         state['matches'][action.product_id][action.side][action.interval] = [ action.match ]


#   # if action.type is 'UPDATE_PROJECTION'

#   #   # console.log action, 'abc'

#   #   path = [ 'projections', action.product_id, action.side, action.interval ]
#   #   lens = R.lensPath path


#   #   view = R.view lens, state

#   #   if view
#   #     state = R.set lens, action.projection, state

#   #     console.log path, R.view lens, state


#   #   unless view

#   #     # ensure product
#   #     unless state['projections'][action.product_id]
#   #       state['projections'][action.product_id] = {}

#   #     unless state['projections'][action.product_id][action.side]
#   #       state['projections'][action.product_id][action.side] = {}

#   #     unless state['projections'][action.product_id][action.side][action.interval]
#   #       state['projections'][action.product_id][action.side][action.interval] = [ action.match ]


#     # console.log 'aaa', state.matches
#     # # Store local unix timestamp to model
#     # action.match.local = state.now.valueOf()

#     # key = [ action.match.product_id, action.match.side ].join( '-' ).toUpperCase()

#     # latestPrice = state.prices[key]
#     # thisPrice = R.pick [ 'trade_id', 'price'], action.match

#     # unless latestPrice
#     #   state.prices[key] = thisPrice

#     # # Only update if trade_id is greater than current
#     # if latestPrice and thisPrice.trade_id > latestPrice.trade_id

#     #   state.prices[key] = thisPrice

#     #   state.positions = positionDetermine state.currencies, state.prices

#     # # Find any proposals that are no longer relevant
#     # # e.g. price is out-of-date and would incur a fee
#     # existingTradeCriteria = (foo)->
#     #   action.match.side is foo.side and action.match.product_id is foo.product_id

#     # index = R.findIndex(existingTradeCriteria)(state.proposals)

#     # if index > 0
#     #   if checkObsoleteTrade state.proposals[index], action.match.price
#     #     state.proposals.splice index, 1

#     # state.matches.push action.match

#   if action.type is 'UPDATE_ACCOUNT'
#     state.currencies[action.currency.currency] = R.pick ['hold', 'balance'], action.currency

#     state.positions = positionDetermine state.currencies, state.prices


#   if action.type is 'ORDER_SENT'
#     currency = action.order.product_id.split('-')[1]
#     side = action.order.side

#     state.currencies[currency].hold = pricing.size( parseFloat( state.currencies[currency].hold ) + parseFloat( action.order.size ) )
#     state.currencies[currency].balance = pricing.size( parseFloat( state.currencies[currency].balance ) - parseFloat( action.order.size ) )

#     state.sent.push action.order

#   if action.type is 'ORDER_RECEIVED'
#     client_oid = action.order.client_oid
#     if client_oid
#       index = R.findIndex(R.propEq('client_oid', client_oid))( state.sent)
#       if index >= 0
#         state.orders.push action.order
#         state.sent.splice( index, 1 )


#   if action.type is 'ORDER_FILLED'
#     order_id = action.order.order_id
#     if order_id
#       index = R.findIndex(R.propEq('order_id', order_id))( state.orders )
#       if index >= 0
#         state.orders.splice( index, 1 )


#   if action.type is 'ORDER_CANCELLED'
#     order_id = action.order.order_id
#     if order_id
#       index = R.findIndex(R.propEq('order_id', order_id))( state.orders )
#       if index >= 0

#         currency = action.order.product_id.split('-')[1]
#         side = action.order.side
#         size = parseFloat action.order.size

#         if 'buy' is side
#           size = -1 * size


#         state.currencies[currency].hold = pricing.size( parseFloat( state.currencies[currency].hold ) - size )
#         state.currencies[currency].balance = pricing.size( parseFloat( state.currencies[currency].balance ) + size )

#         state.orders.splice( index, 1 )



#   updatePredictionsByCurrencySide = ( matches, key )->

#     side = key.split( '-' )[2].toLowerCase()

#     past = moment().subtract( 864, 'seconds' ).utc().unix()
#     future = moment().add( 864, 'seconds' ).utc().unix()


#     minutes = moment().subtract( 864, 'seconds' ).utc().unix()
#     hours = moment().subtract( 8640, 'seconds' ).utc().unix()
#     day = moment().subtract( 86400, 'seconds' ).utc().unix()

#     byTimeFrame = ( doc )->
#        docTime = moment( doc.time ).utc().unix()

#        return 864 if docTime > minutes
#        return 8640 if docTime < minutes and docTime > hours
#        86400

#     makePredictions = ( docs )->
#       predictor = predictions side, future, key
#       predictor docs

#     R.map makePredictions, R.groupBy byTimeFrame, matches




#   updatePredictions = ( currencyIntents )->

#     state.matches = R.sortBy R.prop( 'time' ), state.matches

#     byProductAndSide = ( doc )->
#       [ doc.product_id, doc.side ].join( '-' ).toUpperCase()


#     grouped = R.groupBy byProductAndSide, state.matches

#     foo = R.mapObjIndexed updatePredictionsByCurrencySide, grouped


#     # In order to prevent us make proposals for currencies and sides we don't want
#     # we winnow out those we're not interested in
#     final = {}
#     finalize = ( currencySidePair )->
#       final[ currencySidePair ] = foo[ currencySidePair ]

#     R.forEach finalize, currencyIntents

#     final


#   hasProjection = ( doc )->
#     doc.linear

#   proposalsToArray = ( proposal, key )->
#     proposal.timeframe = key
#     proposal


#   findBestProposal = ( proposals, currencySide )->
#     side = currencySide.split( '-' )[2].toLowerCase()


#     #
#     # if undefined return
#     return proposals unless proposals

#     doable = R.values R.mapObjIndexed proposalsToArray, R.filter hasProjection, proposals

#     ordered = R.sortBy R.prop( 'linear' ), doable

#     if 'sell' is side
#       ordered = R.reverse ordered

#     R.head ordered


#   makeTradeProposal = ( doc, key )->

#     parts = key.split '-'

#     if doc
#       doc.side = parts[2].toLowerCase()
#       doc.product_id = [ parts[0], parts[1] ].join '-'
#       doc.price = doc.linear

#       doc.size = halfsies doc.current, doc.linear, state.currencies[ parts[0] ].balance


#     doc

#   # heartbeat ensures that proposed orders, and active orders don't stagnate
#   if action.type is 'HEARTBEAT'
#     state.heartbeat = action.message


#     start = moment().valueOf()


#     asdfasdf = ( a, b )->
#       asdfasdfasdf = ( c )->
#         [ b, c ].join( '-' ).toUpperCase()

#       R.map asdfasdfasdf, R.keys a


#     state.predictions = updatePredictions R.uniq R.flatten R.values R.mapObjIndexed asdfasdf, state.advice

#     bestPredictions = R.reject R.isNil, R.values R.mapObjIndexed makeTradeProposal, R.mapObjIndexed findBestProposal, state.predictions



#     #
#     #
#     fdsa = ( doc )->
#       handleFractionalSize doc, 0.01

#     dontOverextend = R.filter fdsa, bestPredictions


#     #
#     # TODO could roll into cleanUpTrades??
#     ensureMinimumSize = ( doc )->
#       if doc.size < 0.01
#         doc.size = 0.01

#       doc


#     validBids = R.map ensureMinimumSize, dontOverextend

#     state.proposals = R.map cleanUpTrades, validBids

#     console.log 'HEARTBEAT', ( moment().valueOf() - start ), 'ms'

#   # return
#   state

# module.exports = reducers
