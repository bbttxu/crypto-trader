require('dotenv').config( silent: true )

mongo = require('mongodb').MongoClient
RSVP = require 'rsvp'

getFills = (product)->
  new RSVP.Promise (resolve, reject)->
    mongo.connect process.env.MONGO_URL, (err, db)->
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
