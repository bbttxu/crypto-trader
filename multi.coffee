getBidsSells = require './lib/getBidsSells'
getBidsBuys = require './lib/getBidsBuys'

{
  map
  equals
  sortBy
  prop
  pluck
  addIndex
  view
  set
  forEach
  mapObjIndexed
  isNil
  mergeAll
  reverse
  values
  isEmpty
  sum
  unnest
  reject
  pick
  mergeDeepRight
  lensProp
  lensPath
  view
  set
} = require 'ramda'

log = require './lib/log'

groupBySide = require './lib/groupBySide'

catchError = ( name, callback = log )->
  ( error )->
    callback name, error.response.data.message

throttle = require 'lodash.throttle'

md5 = require 'blueimp-md5'

ensureSellIsMoreThanBuy = require './lib/ensureSellIsMoreThanBuy'

{
  hash
  Promise
} = require 'rsvp'

{
  createStore,
  applyMiddleware
  combineReducers
} = require 'redux'

thunk = require 'redux-thunk'

Redis = require 'ioredis'

sortByCreatedAt = sortBy prop( 'time' )

sortByAbsoluteDPrice = sortBy ( run )->
  Math.abs run.d_price || 0

productReducer = require './reducers/product'
pricingReducer = require './reducers/pricing'
accountsReducer = require './reducers/accounts'
runsReducer = require './reducers/runs'
strategicReducer = require './reducers/strategic'
tacticatlReducer = require './reducers/tactical'
adviceReducer = require './reducers/advice'

getRunsSoldFromStorage = require './lib/getRunsSoldFromStorage'
getRunsBoughtFromStorage = require './lib/getRunsBoughtFromStorage'
# getRunsSoldFromStorage

showStake = require './lib/showStake'

throttleShowStake = throttle showStake, 60 * 1000
# makeProductReducer = ( value, product )->
#   initialState =
#     tick: 0
#     bids: []

#   ( state, action )->
#     console.log product, state, action

#     if typeof state == 'undefined'
#       # log 'initial state is undefined', initialState
#       return initialState

#     # if product isnt action.product
#     #   return state
#     log action.product
#     if not isNil( action.product ) and product is action.product

#       if 'ADD_BID' is action.type
#         start = Date.now()

#         # console.log action

#         bidsPath = lensPath [ action.product, 'bids' ]
#         bidIdsPath = lensPath [ action.product, 'bid_ids' ]
#         bidsHashPath = lensPath [ action.product, 'bids_hash' ]

#         currentBids = view( bidsPath, state ) || []

#         # console.log currentBids


#         state = set bidsPath, sortByCreatedAt( currentBids.concat( action.bid ) ), state

#         bid_ids =  ( pluck 'id', currentBids ).sort()

#         state = set bidIdsPath, bid_ids, state
#         state = set bidsHashPath, md5( bid_ids.join() ), state

#         # log view( bidsHashPath, state ), Date.now() - start, 'ms'

#       state.tick++

#       # return state


#     return state

makeProductReducer = ( key )->
  obj = {}
  obj[ key ] = productReducer( key )
  obj

currencies = [
  'LTC-USD'
  'ETH-USD'
  'BCH-USD'
  'BTC-USD'
  'LTC-BTC'
  'ETH-BTC'
  'BCH-BTC'
]

reducers = mergeAll map makeProductReducer, currencies
reducers.pricing = pricingReducer
reducers.accounts = accountsReducer
reducers.runs = runsReducer
reducers.strategic = strategicReducer
reducers.tactical = tacticatlReducer
reducers.advice = adviceReducer

rootReducer = combineReducers reducers
store = createStore rootReducer, applyMiddleware(thunk.default)


INDEX_INCREMENT = 1000 / currencies.length

dispatchBidsFromStorage = addIndex( map ) ( bid, index = 10 )->
  doIt = ->
    store.dispatch
      type: 'ADD_BID_FROM_STORAGE'
      product: bid.product_id
      bid: bid

  setTimeout doIt, index *INDEX_INCREMENT


dispatchRuns = addIndex( map ) ( run, index = 1 )->
  # console.log run
  doIt = ->
    store.dispatch
      type: 'ADD_RUN_FROM_STORAGE'
      product: run.product_id
      run: run

  # console.log index
  setTimeout doIt, index * INDEX_INCREMENT







accountsChannel = new Redis()

accountsChannel.subscribe "accounts"

accountsChannel.on 'message', ( channel, message )->
  store.dispatch
    type: 'UPDATE_ACCOUNTS'
    accounts: JSON.parse message




_tactical_hash = undefined

store.subscribe ->
  state = store.getState()

  tactical_hash = state.tactical._hash or 'undefinedtacticalhash'

  # console.log _tactical_hash, tactical_hash, equals( tactical_hash, _tactical_hash )

  unless equals tactical_hash, _tactical_hash
    _tactical_hash = tactical_hash

    console.log 'tactical', tactical_hash, state.tactical.proposals




_strategic_hash = undefined

store.subscribe ->
  state = store.getState()

  strategic_hash = state.strategic._hash or 'undefinedstrategichash'

  # console.log _strategic_hash, strategic_hash, equals( strategic_hash, _strategic_hash )

  unless equals strategic_hash, _strategic_hash
    _strategic_hash = strategic_hash

    # console.log 'STRATEGIC_UPDATE', strategic_hash, state.strategic.bids
    store.dispatch
      type: 'STRATEGIC_UPDATE'
      strategic: state.strategic.bids




# _pricing_hash = undefined
# _accounts_hash = undefined

# store.subscribe ->
#   state = store.getState()

#   # console.log state.accounts
#   pricing_hash = state.pricing._hash or undefined
#   accounts_hash = state.accounts._hash or undefined

#   if pricing_hash and accounts_hash

#     # log accounts_hash, pricing_hash
#     unless equals _pricing_hash, pricing_hash or equals _accounts_hash, accounts_hash
#       # log accounts_hash, pricing_hash

#       _pricing_hash = pricing_hash
#       _accounts_hash = accounts_hash

#       throttleShowStake  state.accounts.accounts, state.pricing.prices



addPriceKey = map ( thing )->
  return
    price: thing


determineNewTrades = ( stats, prices )->

  determineTradesOffPrices = ( value, currency )->

    frontline = {}

    buyLens = lensProp 'buy'
    buyPriceLens = lensPath [ currency, 'buy' ]
    buyRunsLens = lensPath [ currency, 'buy', 'avg' ]

    buyPrice = view buyPriceLens, prices
    buyDelta = view buyRunsLens, stats

    buyDope = reject isNil, [ buyPrice, buyDelta ]

    if buyDope.length is 2
      frontline = set buyLens, sum( buyDope ), frontline




    sellLens = lensProp 'sell'
    sellPriceLens = lensPath [ currency, 'sell' ]
    sellRunsLens = lensPath [ currency, 'sell', 'avg' ]

    sellPrice = view sellPriceLens, prices
    sellDelta = view sellRunsLens, stats

    sellDope = reject isNil, [ sellPrice, sellDelta ]

    if sellDope.length is 2
      frontline = set sellLens, sum( sellDope ), frontline

    frontline = ensureSellIsMoreThanBuy frontline

    addPriceKey frontline





  adfadfadf = mapObjIndexed determineTradesOffPrices, stats

  # log adfadfadf
  adfadfadf




_pricing_hash = undefined
_runs_stats_hash = undefined

store.subscribe ->
  state = store.getState()

  pricing_hash = state.pricing._hash or undefined
  runs_stats_hash = state.runs.stats_hash or undefined

  if runs_stats_hash and pricing_hash

    unless equals _runs_stats_hash, runs_stats_hash

      _runs_stats_hash = runs_stats_hash

      unless equals _pricing_hash, pricing_hash

        frontline = determineNewTrades state.runs.stats, state.pricing.prices

        store.dispatch
          type: 'FRONTLINE_UPDATE'
          frontline: frontline

        # _runs_stats_hash = runs_stats_hash
        _pricing_hash = pricing_hash



basicBids = map ( foo )->
  pick [ 'price', 'side', 'size', 'reason' ], foo

start = ( product )->
  _bids_hash = undefined
  store.subscribe ->
    state = store.getState()

    if state[ product ]
      bids_hash = state[ product ].bids_hash or undefined

      unless equals _bids_hash, bids_hash

        doIt = ->
          # console.log basicBids state[ product ].bids
          store.dispatch
            type: 'UPDATE_STRATEGIC_BIDS'
            bids:  basicBids state[ product ].bids
            product: product


        setTimeout doIt, 10

        # log 'BIDS', product, state[ product ].tick, state[ product ].bids_hash
        _bids_hash = bids_hash






  log product

  hash(
    getBidsBuys: getBidsBuys product
    getBidsSells: getBidsSells product
    runsSold: getRunsSoldFromStorage( product_id: product )
    runsBought: getRunsBoughtFromStorage( product_id: product )
  ).then(
    ( results )->
      new Promise ( resolve, rejectPromise )->
        dispatchBidsFromStorage( results.getBidsBuys )
        dispatchBidsFromStorage( results.getBidsSells )
        doIt = ->
          resolve results

        setTimeout doIt, 1000
        results

  ).then(
    ( results )->
      # console.log results.runs
      dispatchRuns( reverse( sortByAbsoluteDPrice( results.runsSold ) ) )
      dispatchRuns( reverse( sortByAbsoluteDPrice( results.runsBought ) ) )
      results

  ).then(
    ( results )->

      feedChannel = new Redis()

      feedChannel.subscribe "feed:#{product}"

      feedChannel.on 'message', ( channel, message )->
        message = JSON.parse message

        if 'match' is message.type
          store.dispatch
            type: 'ADD_MATCH'
            match: message

        # console.log message

        # if 'done' is message.type and 'canceled' is message.reason
        #   store.dispatch
        #     type: 'BID_CANCELLED'
        #     product: product
        #     bid: message


        if 'done' is message.type and 'filled' is message.reason
          # console.log message
          store.dispatch
            type: 'UPDATE_PRICING'
            # product: product
            match: message

        # console.log message

      results

  ).then(
    ( results )->

      store



      results
  ).catch(
    catchError( product )
  )


forEach start, currencies



###
            .___     .__
_____     __| _/__  _|__| ____  ____
\__  \   / __ |\  \/ /  |/ ___\/ __ \
 / __ \_/ /_/ | \   /|  \  \__\  ___/
(____  /\____ |  \_/ |__|\___  >___  >
     \/      \/              \/    \/
###

# console.log 'advice'

adviceChannel = new Redis()

adviceChannel.subscribe "advice"

adviceChannel.on 'message', ( channel, jsonString )->
  console.log 'received', channel, jsonString

  store.dispatch
    type: 'ADVICE_UPDATE'
    advice: JSON.parse jsonString


