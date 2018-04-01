initialState =
  tick: 0
  bids: []
  runs: []

log = require '../lib/log'

showStatus = require '../lib/showStatus'

{
  isNil
  lensPath
  view
  set
  pluck
  sortBy
  prop
  findIndex
  propEq
  merge
  reject
  contains
} = require 'ramda'

md5 = require 'blueimp-md5'

assessBids = require '../lib/assessBids'

# saveBidToStorage = require '../lib/saveBidToStorage'

sortByCreatedAt = sortBy prop( 'time' )


productReducer = ( product )->
  ( state, action )->
    # log state

    if typeof state == 'undefined'
      return initialState

    if action and action.product and product is action.product

      if not isNil( action.product ) and product is action.product

        if 'ADD_BID_FROM_STORAGE' is action.type
          start = Date.now()

          bidsPath = lensPath [ 'bids' ]
          bidIdsPath = lensPath [ 'bid_ids' ]
          bidsHashPath = lensPath [ 'bids_hash' ]

          currentBids = view( bidsPath, state ) || []

          state = set bidsPath, sortByCreatedAt( currentBids.concat( action.bid ) ), state

          bid_ids =  ( pluck 'id', currentBids ).sort()

          state = set bidIdsPath, bid_ids, state
          state = set bidsHashPath, md5( bid_ids.join() ), state


          # console.log assessBids state.bids
          # console.log showStatus state.bids

          # log view( bidsHashPath, state ), Date.now() - start, 'ms'

        # if 'ADD_RUN_FROM_STORAGE' is action.type
        #   unless 0 is action.run.d_price or 0 is action.run.d_time
        #     # log 'ADD_RUN', state.runs.length, moment( action.run.end ).fromNow()
        #     state.runs.push action.run


        if 'BID_CANCELLED' is action.type

          index = findIndex propEq( 'id', action.bid.order_id ), state.bids

          # console.log action.bid.order_id
          if index > -1
            # log 'BID_CANCELLED', action.bid.order_id, action.bid
            updatedBid = merge state.bids[ index ], action.bid

            state.bids = reject propEq( 'id', action.bid.order_id ), state.bids

            state.bids.push updatedBid

            # saveBidToStorage updatedBid

        # if 'ADD_MATCH' is action.type
        #   console.log 'ADD_MATCH', product, action

        if 'MATCH_FILLED' is action.type
          console.log 'MATCH_FILLED', product, action
          # console.log action.match

          index = findIndex propEq( 'id', action.match.order_id ), state.bids

          if index > -1
            log 'MATCH_FILLED', JSON.stringify action.match
            updatedBid = merge state.bids[ index ], action.match

            state.bids = reject propEq( 'id', action.match.order_id ), state.bids

            state.bids.push updatedBid

            if contains action.match.side, state.advice
              makeCounterBid( action.match )

            # saveBidToStorage updatedBid



        state.tick++


    state

module.exports = productReducer
