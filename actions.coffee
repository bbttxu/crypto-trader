Client = require './lib/coinbase-public-client'
client = Client 'BTC-USD'

R = require 'ramda'

actions =
  ORDER_MATCHED: 'ORDER_MATCHED'
  REQUEST_STATS: 'REQUEST_STATS'
  UPDATE_STATS: 'UPDATE_STATS'
  UPDATE_ACCOUNTS: 'UPDATE_ACCOUNTS'

creators =
  requestStats: (product)->
    type: actions.REQUEST_STATS
    product: product

  fetchStats: (product)->
    onSuccess = (foo)->
      console.log 'success', foo

    onFail = (foo)->
      console.log 'fail', foo

    (dispatch)->
      client.stats().then(onSuccess).then(onFail)

module.exports = R.mergeAll [actions, creators]


# actionCreaters =
#   updateStats = (dispatch)->



# module.exports = actionCreaters
