require('dotenv').config( silent: true )

# mongo = require('mongodb').MongoClient
RSVP = require 'rsvp'

moment = require 'moment'

mongoConnection = require('../lib/mongoConnection')

RESET_DATE = "2017-11-23T00:00:00.000Z"

getFills = (product)->
  new RSVP.Promise (resolve, reject)->
    mongoConnection().then (db)->
      collection = db.collection 'fill'

      onError = (err)->
        console.log 'getFills.err', err
        reject err

      callback = ( results )->
        resolve results

      search =
        product_id: product
        created_at:
          $gte: RESET_DATE

      collection.find(
        search
      ).sort(
        trade_id: 1
      ).toArray().then(
        resolve
      ).catch(
        onError
      )

module.exports = getFills
