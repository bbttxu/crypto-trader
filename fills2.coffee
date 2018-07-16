SIZE_ZERO = '0.00000000'


config = require './config'

RSVP = require( 'rsvp' )

{
  keys
  take
  map
  length
  pluck
  groupBy
  prop
  sortBy
  pick
  where
  __
  lt
  gt
  filter
  addIndex
  sum
  reject
  uniq
  all
  equals
  take
} = require 'ramda'

# reconcile = require './lib/reconciler'

moment = require 'moment'

# {
#   createStore,
#   applyMiddleware
#   combineReducers
# } = require 'redux'

# thunk = require 'redux-thunk'


# fillsReducer = require './reducers/fills'
# # reducers.fills = fillsReducer

# # rootReducer = combineReducers reducers
# store = createStore fillsReducer, applyMiddleware(thunk.default)


{
  getFills
  # getAccounts
} = require './lib/gdax-client'

# shuffle = require('knuth-shuffle').knuthShuffle

currencies = keys config.currencies
# currencies = take 1, shuffle currencies


console.log currencies



whatWasOneDayAgo = moment().subtract( 1, 'day' )
whatYearWasItADayAgo = whatWasOneDayAgo.year()
areWeInTheYearWeCareAbout = equals whatYearWasItADayAgo

# console.log whatYearWasItADayAgo

# mapIndex = addIndex map

# reconcileBuysWithSells = ( incomingBuys, incomingSells )->
#   split = groupBy prop( 'side' ), trades


#   buys = incomingBuys
#   sells = incomingSells

#   console.log incomingBuys, incomingSells
#   values = []


#   findSale = ( notused, buyIndex )->
#     console.log 'buy', buyIndex
#     buy = buys[ buyIndex ]

#     reconcileBuyWithSell = ( sell, sellIndex )->
#       console.log 'sell', sellIndex


#       a = reconcile buy, sell
#       # console.log a


#       buys[ buyIndex ] = a[0]
#       # console.log 'buys', buys

#       sells[ sellIndex ] = a[1]
#       values = values.concat a[2]

#       # console.log values.sort()
#       a



#     mapIndex reconcileBuyWithSell, sells

#     # console.log 'sells', sells

#   mapIndex findSale, buys


#   return
#     buys: buys
#     sells: sells
#     value: sum values

# shuffle = require('knuth-shuffle').knuthShuffle
# saveFill = require './lib/saveFill'
{addFillToQueue} = require './workers/saveFillToStorage'

# addFill = ( fill )->
#   store.dispatch
#     type: 'FILLS_AD'
#     fill: fill
#   # console.log fill
#   fill

getYearFromDate = ( date )->
  moment( date ).year()


# getAccounts().then( console.log );

# getFillsFromStorage = require './lib/getFills'

handleCurrency = ( currency, params = {} )->

  # getFillsFromStorage( currency )
  #   .then( pluck( 'trade_id' ) )
  #   .then( uniq )
  #   .then(
  #     (results)->
  #       # console.log results
  #       console.log uniq( results ).length
  #       results
  #   )
  #   .then( console.log )

  getFills( currency, params )
    # .then( sortBy prop( 'price' ) )
    # .then( shuffle )
    # .then( take 10 )
    # ).then(
    #   map pick( ['price', 'size', 'side', 'created_at', 'trade_id'])
    .then( map addFillToQueue )
    .then( RSVP.all )
    .then(
      ( fills )->
        dates = ( pluck 'created_at', fills ).sort()

        years = uniq map getYearFromDate, dates
        console.log years, dates[0]

        if all areWeInTheYearWeCareAbout, years
          foo = ->
            handleCurrency(
              currency,
              after: ( pluck 'trade_id', fills ).sort()[0]
            )

          setTimeout foo, 1000 * currencies.length


          # console.log fills.length
        fills
    )
    .catch( console.log )
    .finally(
      ()->
        console.log 'finally', currency, params
    )



map handleCurrency, currencies


# saveFills = require('./save2')(config)

# saveFills()
# setInterval saveFills, (1000 * 60 * 10)
