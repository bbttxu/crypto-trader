getBids = require './lib/getBids'

{
  map
  equals
  sortBy
  prop
  pluck
  addIndex
  lensPath
  view
  set
  forEach
  mapObjIndexed
  isNil
  mergeAll
  reverse
} = require 'ramda'

log = require './lib/log'

catchError = ( name, callback = log )->
  ( error )->
    callback name, error.response.data.message

throttle = require 'lodash.throttle'

md5 = require 'blueimp-md5'

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

getRunsFromStorage = require './lib/getRunsFromStorage'

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

rootReducer = combineReducers reducers
store = createStore rootReducer, applyMiddleware(thunk.default)


INDEX_INCREMENT = 32

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



_pricing_hash = undefined
_accounts_hash = undefined

store.subscribe ->
  state = store.getState()

  # console.log state.accounts
  pricing_hash = state.pricing._hash or undefined
  accounts_hash = state.accounts._hash or undefined

  if pricing_hash and accounts_hash

    # log accounts_hash, pricing_hash
    unless equals _pricing_hash, pricing_hash or equals _accounts_hash, accounts_hash
      # log accounts_hash, pricing_hash

      _pricing_hash = pricing_hash
      _accounts_hash = accounts_hash

      throttleShowStake  state.accounts.accounts, state.pricing.prices



_runs_stats_hash = undefined
store.subscribe ->
  state = store.getState()

  if state.runs.stats_hash

    runs_stats_hash = state.runs.stats_hash

    unless equals _runs_stats_hash, runs_stats_hash
      log 'RUNS', state.runs.stats_hash
      _runs_stats_hash = runs_stats_hash


start = ( product )->
  # _bids_hash = undefined
  # store.subscribe ->
  #   state = store.getState()

  #   if state[ product ]
  #     bids_hash = state[ product ].bids_hash or undefined

  #     unless equals _bids_hash, bids_hash

  #       log 'BIDS', product, state[ product ].tick, bids_hash
  #       _bids_hash = bids_hash






  log product

  hash(
    bids: getBids product, reason: 'filled'
    runs: getRunsFromStorage( product_id: product )
    # runs: getRunsFromStorage( product_id: product )
  ).then(
    ( results )->
      # console.log results.bids.length, 'bids'
      new Promise ( resolve, rejectPromise )->
        dispatchBidsFromStorage( results.bids )
        doIt = ->
          resolve results

        setTimeout doIt, 1000
        results

  ).then(
    ( results )->
      dispatchRuns( reverse( sortByAbsoluteDPrice( results.runs ) ) )
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
