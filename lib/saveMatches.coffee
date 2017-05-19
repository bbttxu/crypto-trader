require('dotenv').config( silent: true )

R = require 'ramda'
mongo = require('mongodb').MongoClient
RSVP = require 'rsvp'
moment = require 'moment'

necessaryFields = ['side', 'size', 'price', 'product_id', 'time', 'trade_id']

mongoConnection = undefined
mongoCollection = undefined

mongo.connect process.env.MONGO_URL, (err, db)->
  if err
    console.log 'error with mongo connection', err

  mongoConnection = db
  mongoCollection = db.collection 'matches'

saveMatches = ( matches )->
  new RSVP.Promise (resolve, reject)->

    details = R.map R.pick( necessaryFields ), matches

    mongoCollection.insert details, (err, whiz)->
      reject err if err
      resolve details


module.exports = saveMatches
