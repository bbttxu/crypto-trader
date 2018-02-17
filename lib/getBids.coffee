RSVP = require 'rsvp'

mongoConnection = require('../lib/mongoConnection')

{
  merge
} = require 'ramda'

moment = require 'moment'

getBids = ( product, query = {} )->

  console.log product, query
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
        # time:
        #   $gt: moment().subtract( 7, 'days' ).toISOString()

      console.log  merge search, query

      collection.find(
        merge search, query
      ).sort(
        time: 1
      ).toArray().then(
        callback
      ).catch(
        onError
      )


module.exports = getBids
