require('dotenv').config( silent: true )

mongoConnection = require('../lib/mongoConnection')

RSVP = require 'rsvp'

getFills = (product)->
  mongoConnection().then (db)->
    collection = db.collection 'matches'

    onError = (err)->
      db.close()
      console.log 'dataMatches.err', err
      reject err

    callback = (results)->
      db.close()

      resolve results

    search =
      product_id: product

    collection.find(search).sort(trade_id: 1).toArray().then(callback).catch(onError)


module.exports = getFills
