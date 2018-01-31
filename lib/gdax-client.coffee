require('dotenv').config({silent: true})
Gdax = require 'gdax'
RSVP = require 'rsvp'

# Func program lib
{
  map
  keys
  isNil
} = require 'ramda'

moment = require 'moment'

# Some
{
  get
} = require 'axios'


exit = require './exit'

###
               __  .__               .____________ .__  .__               __
_____   __ ___/  |_|  |__   ____   __| _/\_   ___ \|  | |__| ____   _____/  |_
\__  \ |  |  \   __\  |  \_/ __ \ / __ | /    \  \/|  | |  |/ __ \ /    \   __\
 / __ \|  |  /|  | |   Y  \  ___// /_/ | \     \___|  |_|  \  ___/|   |  \  |
(____  /____/ |__| |___|  /\___  >____ |  \______  /____/__|\___  >___|  /__|
     \/                 \/     \/     \/         \/             \/     \/

local scoped client
if we need to restart, we have a local scoped variable onto which we can re-attach a new instance
###

# 0 auth mechanism
authedClient = ->
  client = new Gdax.AuthenticatedClient(process.env.API_KEY, process.env.API_SECRET, process.env.API_PASSPHRASE)
  # console.log moment().format(), 'gdax authedClient', client
  client


# 1 mechanism to create auth mechanism to gdax
# reinitAuthedClient = ->
#   authedClient = new Gdax.AuthenticatedClient(process.env.API_KEY, process.env.API_SECRET, process.env.API_PASSPHRASE)
#   console.log moment().format(), 'gdax authedClient', authedClient

# reinitAuthedClient() # 2 get things started


clientReject = ( err )->
  console.log 'gdax client by error clientReject', err


  exit()



###
                __  .__               .___
  _____   _____/  |_|  |__   ____   __| _/______
 /     \_/ __ \   __\  |  \ /  _ \ / __ |/  ___/
|  Y Y  \  ___/|  | |   Y  (  <_> ) /_/ |\___ \
|__|_|  /\___  >__| |___|  /\____/\____ /____  >
      \/     \/          \/            \/    \/
###

cancelAllOrders = ( currencies = [] )->
  new RSVP.Promise (resolve1, rejectPromise1)->
    promiseCancelCurrencyOrder = ( currency )->
      new RSVP.Promise (resolve2, reject2)->
        authedClient().cancelAllOrders { product_id: currency }, (err, results)->
          if err or undefined is results
            console.log 'cancelAllOrders.err', err
            reject2 err
          else
            resolve2 results.body

    cancelAllCurrencyOrders = map promiseCancelCurrencyOrder, currencies

    rejectPromise = ( promise )->
      rejectPromise1 promise

    resolveIssues = ( issues )->
      resolve1 issues

    RSVP.allSettled( cancelAllCurrencyOrders ).then( resolveIssues ).catch( rejectPromise )


getProduct24HrStats = ( product )->
  new RSVP.Promise (resolve, rejectPromise )->
    publicClient = new Gdax.PublicClient product

    callback = (err, json)->
      if err
        rejectPromise err

      body = JSON.parse json.body

      unless body
        rejectPromise
          func: 'getProduct24HrStats'
          message: 'no JSON response body'
          json: json

      if isNil body.message

        obj = {}
        obj[ product ] = body

        resolve obj

      rejectPromise body

    publicClient.getProduct24HrStats callback


stats = ( currencies = [] )->
  new RSVP.Promise ( resolve, reject )->

    allCurrencyStats = map getProduct24HrStats, currencies

    rejectPromise = ( promise )->
      reject promise

    resolveIssues = ( issues )->
      resolve issues

    RSVP.all( allCurrencyStats ).then( resolveIssues ).catch( rejectPromise )

#
# single stat for single product_id
stat = ( product_id, params = granularity: 60 )->
  get(
    "https://api.gdax.com/products/#{product_id}/candles",
    { params: params }
  )


getAccounts = ( currency )->
  # console.log currency
  new RSVP.Promise ( resolve, rejectPromise )->
    callback = (err, json)->
      rejectPromise err if err
      if json
        resolve JSON.parse( json.toJSON().body )

      resolve []

    authedClient().getAccounts callback

cancelOrder = ( order )->
  new RSVP.Promise (resolve, rejectPromise )->
    callback = (err, data)->
      if err
        console.log 'err cancelOrder', err, order
        rejectPromise false

      unless data
        rejectPromise false

      payload = JSON.parse data.body

      # we ensure the trade was deleted by checking that it was already removed from the orderbook
      if 'NotFound' is payload.message
        resolve true

      else
        rejectPromise payload.message


    authedClient().cancelOrder order, callback

buy = ( order )->
  new RSVP.Promise ( resolve, reject )->
    callback = ( err, result )->
      if err
        clientReject err
        reject err

      resolve result

    authedClient().buy order, callback

sell = ( order )->
  new RSVP.Promise ( resolve, reject )->
    callback = ( err, result )->
      reject err if err
      resolve result

    authedClient().sell order, callback



getFills = (product = product_id)->
  new RSVP.Promise (resolve, reject)->
    authedClient().getFills {product_id: product}, (err, data)->
      if err
        data = JSON.parse err.body
        console.log 'err getFills', data, order
        reject err.body

      resolve JSON.parse data.body


getOrders = (product_id)->
  new RSVP.Promise (resolve, reject)->
    callback = ( result )->
      console.log 'result', result
      resolve result


    authedClient().getOrders( product_id, callback )



###                                  __
  ____ ___  _________   ____________/  |_  ______
_/ __ \\  \/  /\____ \ /  _ \_  __ \   __\/  ___/
\  ___/ >    < |  |_> >  <_> )  | \/|  |  \___ \
 \___  >__/\_ \|   __/ \____/|__|   |__| /____  >
     \/      \/|__|                           \/###

module.exports =
  cancelAllOrders: cancelAllOrders
  getProduct24HrStats: getProduct24HrStats

  # multiple or single
  stats: stats
  stat: stat

  getAccounts: getAccounts

  cancelOrder: cancelOrder
  buy: buy
  sell: sell

  getFills: getFills
  getOrders: getOrders
