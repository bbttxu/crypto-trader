RSVP = require 'rsvp'

mongoConnection = require('../lib/mongoConnection')

{
  merge
} = require 'ramda'

moment = require 'moment'

getBids = ( product, query = {} )->
  new RSVP.Promise (resolve, reject)->
    mongoConnection().then (db)->
      collection = db.collection 'bids'

      onError = (err)->
        console.log 'getBids.err', err
        reject err

      callback = (results)->
        resolve results

      search =
        product_id: product
        created_at:
          $gt: moment().subtract( 24, 'hours' ).toDate()


      collection.find(
        merge search, query
      ).sort(
        trade_id: 1
      ).toArray().then(
        callback
      ).catch(
        onError
      )


module.exports = getBids
