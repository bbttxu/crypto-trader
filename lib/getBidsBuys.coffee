{
  Promise
} = require 'rsvp'

mongoConnection = require('../lib/mongoConnection')

moment = require 'moment'

{
  mergeAll
} = require 'ramda'

required = {
  side: 'buy'
  reason: 'filled'
}

getBidsSells = ( product, query = {} )->
  new Promise (resolve, reject)->
    mongoConnection().then (db)->
      collection = db.collection 'bids'

      onError = (err)->
        console.log 'getBids.err', err
        reject err

      callback = (results)->
        resolve results

      search =
        product_id: product
        time:
          $gt: moment().subtract( 28, 'days' ).toISOString()


      collection.find(
        mergeAll [ search, query, required ]
      ).limit(
        3
      ).sort(
        price: 1
      ).toArray().then(
        callback
      ).catch(
        onError
      )



module.exports = getBidsSells
