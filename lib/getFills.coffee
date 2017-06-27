require('dotenv').config( silent: true )

# mongo = require('mongodb').MongoClient
RSVP = require 'rsvp'

mongoConnection = require('../lib/mongoConnection')

getFills = (product)->
  new RSVP.Promise (resolve, reject)->
    mongoConnection().then (db)->
      collection = db.collection 'fill'

      onError = (err)->
        db.close()
        console.log 'getFills.err', err
        reject err

      callback = (results)->
        db.close()
        resolve results

      search =
        product_id: product

      collection.find(search).sort(trade_id: 1).toArray().then(callback).catch(onError)


module.exports = getFills
