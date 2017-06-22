require('dotenv').config( silent: true )

R = require 'ramda'
mongo = require('mongodb').MongoClient
RSVP = require 'rsvp'
moment = require 'moment'

mongoConnection = require('../lib/mongoConnection')

necessaryFields = ['side', 'size', 'price', 'product_id', 'time', 'trade_id']

#
#
saveMatches = ( matches )->
  new RSVP.Promise (resolve, reject)->
    mongoConnection.then (db)->

      matchesCollection = db.collection 'matches'

      details = R.map R.pick( necessaryFields ), matches

      matchesCollection.insert details, (err, whiz)->
        reject err if err

        resolve details


module.exports = saveMatches
