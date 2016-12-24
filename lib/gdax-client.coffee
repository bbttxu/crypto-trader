require('dotenv').config({silent: true})
Gdax = require 'gdax'
RSVP = require 'rsvp'
R = require 'ramda'

authedClient = new Gdax.AuthenticatedClient(process.env.API_KEY, process.env.API_SECRET, process.env.API_PASSPHRASE)

cancelAllOrders = ( currencies = [] )->
  new RSVP.Promise (resolve, reject)->
    promiseCancelCurrencyOrder = ( currency )->
      new RSVP.Promise (resolve, reject)->
        authedClient.cancelAllOrders { product_id: currency }, (err, results)->
          if err
            console.log 'cancelAllOrders.err', err
            reject err
          else
            resolve results.body

    cancelAllCurrencyOrders = R.map promiseCancelCurrencyOrder, currencies

    rejectPromise = ( promise )->
      reject promise

    resolveIssues = ( issues )->
      resolve issues

    RSVP.allSettled( cancelAllCurrencyOrders ).then( resolveIssues ).catch( rejectPromise )


getProduct24HrStats = ( product )->
  new RSVP.Promise (resolve, reject)->
    publicClient = new Gdax.PublicClient product

    callback = (err, json)->
      if err
        reject err

      obj = {}
      obj[ product ] = JSON.parse json.body

      resolve obj

    publicClient.getProduct24HrStats callback


stats = ( currencies = [] )->
  new RSVP.Promise ( resolve, reject )->

    allCurrencyStats = R.map getProduct24HrStats, currencies

    rejectPromise = ( promise )->
      reject promise

    resolveIssues = ( issues )->
      # console.log 'resolveIssues', issues
      resolve issues

    RSVP.all( allCurrencyStats ).then( resolveIssues ).catch( rejectPromise )

getAccounts = ( currency )->
  console.log currency
  new RSVP.Promise ( resolve, reject )->
    callback = (err, json)->
      reject err if err

      resolve JSON.parse json.body

    authedClient.getAccounts callback

cancelOrder = ( orderID )->
  new RSVP.Promise ( resolve, reject )->
    callback = ( err, result )->
      reject err if err
      resolve result

    authedClient.cancelOrder orderID, callback

buy = ( order )->
  new RSVP.Promise ( resolve, reject )->
    callback = ( err, result )->
      reject err if err
      resolve result

    authedClient.buy order, callback

sell = ( order )->
  new RSVP.Promise ( resolve, reject )->
    callback = ( err, result )->
      reject err if err
      resolve result

    authedClient.sell order, callback


module.exports =
  cancelAllOrders: cancelAllOrders
  getProduct24HrStats: getProduct24HrStats
  stats: stats
  getAccounts: getAccounts

  cancelOrder: cancelOrder
  buy: buy
  sell: sell

