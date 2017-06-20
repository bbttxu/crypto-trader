require('dotenv').config( silent: true )

# R = require 'ramda'
# mongo = require('mongodb').MongoClient
RSVP = require 'rsvp'
# moment = require 'moment'

mongoConnection = require('../lib/mongoConnection')

necessaryFields = ['side', 'size', 'price', 'product_id', 'time', 'trade_id']

# mongoConnection = undefined
# mongoCollection = undefined

# mongo.connect process.env.MONGO_URL, (err, db)->
#   if err
#     console.log 'error with mongo connection; savePositions', err

#   mongoConnection = db
#   mongoCollection = db.collection 'positions'


savePositions = ( position )->
  new RSVP.Promise (resolve, reject)->
    mongoConnection.then (db)->
      positions = db.collection 'positions'

      positions.insert position, (err, whiz)->
        reject err if err
        resolve position


module.exports = savePositions
