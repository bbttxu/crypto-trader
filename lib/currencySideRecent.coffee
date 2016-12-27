require('dotenv').config( silent: true )

mongo = require('mongodb').MongoClient
RSVP = require 'rsvp'
moment = require 'moment'


currencySideRecent = ( product, side, intervalUnits = 1, intervalLength = 'hour' )->
  ago = moment().subtract( intervalUnits, intervalLength )

  search =
    product_id: product
    side: side
    time:
      $gte: ago.toISOString()


  new RSVP.Promise (resolve, reject)->
    throwCurrencySideRecentError = (err)->
      console.log err
      reject err

    mongo.connect process.env.MONGO_URL, (err, db)->
      throwCurrencySideRecentError err if err

      collection = db.collection 'matches'

      foo = collection.find( search ).toArray (err, docs)->
        throwCurrencySideRecentError err if err
        db.close()

        resolve docs

module.exports = currencySideRecent
