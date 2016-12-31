require('dotenv').config( silent: true )

R = require 'ramda'
mongo = require('mongodb').MongoClient
RSVP = require 'rsvp'
moment = require 'moment'

necessaryFields = ['side', 'size', 'price', 'product_id', 'time', 'trade_id']


saveMatches = (match)->
  new RSVP.Promise (resolve, reject)->
    mongo.connect process.env.MONGO_URL, (err, db)->
      reject err if err

      collection = db.collection 'matches'

      collection.findOne {trade_id: match.trade_id}, (err, gee)->
        reject err if err

        if gee is null
          details = R.pick necessaryFields, match

          collection.insertOne details, (err, whiz)->
            reject err if err
            db.close()
            resolve details

        else
          db.close()
          resolve true


module.exports = saveMatches
