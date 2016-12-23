require('dotenv').config( silent: true )

R = require 'ramda'
moment = require 'moment'
redux = require 'redux'
thunk = require 'redux-thunk'

gdax = require './lib/gdax-client'

predictions = require './lib/predictions'
proposals = require './lib/proposals'
currencySideRecent = require './lib/currencySideRecent'

config = require './config'
ml = require './ml'


{ createStore, applyMiddleware } = require 'redux'

initalState =
  currencies: {}
  prices: {}
  predictions: {}
  matches: {}

reducers = (state, action) ->

  if typeof state == 'undefined'
    return initalState

  if action.type is 'UPDATE_ACCOUNT'
    state.currencies[action.currency.currency] = R.pick ['hold', 'balance'], action.currency

  if action.type is 'ORDER_MATCHED'
    # console.log 'ORDER_MATCHED', action.match
    key = [ action.match.product_id, action.match.side ].join( '-' ).toUpperCase()

    state.prices[key] = R.pick [ 'time', 'price'], action.match

    unless state.matches[key]
      state.matches[key] = []

    state.matches[key].push action.match

    byTime = ( doc )->
      moment( doc.time ).valueOf()

    state.matches[key] = R.sortBy byTime, state.matches[key]

    future = moment().add( 5 * 60, 'second' ).utc().unix()
    predictor = predictions action.match.side, future, key

    state.predictions[key] = predictor state.matches[key]

  state

store = createStore reducers, applyMiddleware(thunk.default)

store.subscribe (foo)->
  # keys = [ 'prices', 'predictions', 'matches' ]
  # keys = [ 'prices', 'predictions' ]
  keys = [ 'predictions' ]
  # keys = [ 'predictions', 'matches' ]
  keys = [ 'predictions', 'currencies' ]

  state = store.getState()

  # console.log new Date(), R.keys store.getState()
  console.log new Date()

  predictionResults = R.values R.pick [ 'predictions' ], state

  proposals ( R.pick [ 'currencies' ], state ), predictionResults
  # bySide = (foo)->
  #   console.log 'a', R.keys( foo )
  #   foo

  # console.log predictionResults


# foo = ->
#   ml( R.keys config.currencies )

# foo()
# setInterval foo, 20 * 1000


universalBad = ( err )->
  console.log 'bad', err
  throw err if err




# Update Account info


getRelevantCurrencies = ( currencyPairs )->
  split = ( currencyPair )->
    currencyPair.split '-'

  R.uniq R.flatten R.map split, currencyPairs


showAccounts = ( results )->
  currentlyTradedCurrencies = getRelevantCurrencies R.keys config.currencies

  currentlyTraded = ( result )->
    R.contains result.currency, currentlyTradedCurrencies

  dispatchCurrencyBalance = ( currency )->

    store.dispatch
      type: 'UPDATE_ACCOUNT'
      currency: currency

  R.map dispatchCurrencyBalance, R.map R.pick([ 'currency', 'hold', 'balance' ]), R.filter currentlyTraded, results

updateAccounts = ->
  gdax.getAccounts().then( showAccounts )

updateAccounts()
setInterval updateAccounts, 59 * 60 * 1000




# Update on matches
Gdax = require 'gdax'
# websocket = new Gdax.WebsocketClient()
# websocket.on 'message', (data)->
#   console.log data


Gdax = require('gdax')
authentication =
  secret: process.env.API_SECRET
  key: process.env.API_KEY
  passphrase: process.env.API_PASSPHRASE

# websocket = new (Gdax.WebsocketClient)(null, null, authentication)
# websocket.on 'message', (data) ->
#   console.log data

currencyStream = (product)->
  # console.log 'stream', product
  stream = new (Gdax.WebsocketClient)(product, null, authentication)

  stream.on 'error', (foo)->

    console.log 'error'
    console.log foo


  stream.on 'message', (foo)->
    # console.log product, foo
    if foo.type is 'match'
      store.dispatch
        type: 'ORDER_MATCHED'
        match: foo


R.map currencyStream, R.keys config.currencies









dispatchMatch = ( match )->
  store.dispatch
    type: 'ORDER_MATCHED'
    match: match


hydrateRecentCurrency = ( product_id )->
  hydrateRecentCurrencySide = ( side )->
    currencySideRecent( product_id, side, 15, 'minute' ).then ( matches )->
      R.map dispatchMatch, matches


  R.map hydrateRecentCurrencySide, [ 'sell', 'buy' ]

R.map hydrateRecentCurrency, R.keys config.currencies




