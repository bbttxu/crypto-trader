require('dotenv').config( silent: true )

# mongo = require('mongodb').MongoClient
RSVP = require 'rsvp'
moment = require 'moment'

mongoConnection = require('./mongoConnection')

#
#
currencySideRecent = ( product_id, side, intervalUnits = 1, intervalLength = 'hour' )->
  ago = moment().subtract( intervalUnits, intervalLength )


  search =
    product_id: product_id
    side: side
    time:
      $gte: ago.toISOString()



  new RSVP.Promise (resolve, reject)->


    throwCurrencySideRecentError = (err)->
      console.log 'zzzzaaasss'
      console.log err
      reject err


    mongoConnection().then (db)->

      matchesCollection = db.collection 'matches'

      matchesCollection.find( search ).toArray().then (docs)->

        resolve docs

module.exports = currencySideRecent
