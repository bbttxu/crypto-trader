RSVP = require 'rsvp'

mongoConnection = require('../lib/mongoConnection')

getBids = (product)->
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

      collection.find(search).sort(trade_id: 1).toArray().then(callback).catch(onError)


module.exports = getBids
