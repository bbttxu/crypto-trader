require('dotenv').config( silent: true )

mongo = require('mongodb').MongoClient
RSVP = require 'rsvp'
moment = require 'moment'

saveFill = (fill)->
  new RSVP.Promise (resolve, reject)->
    mongo.connect process.env.MONGO_URL, (err, db)->
      reject err if err

      collection = db.collection 'fill'


      collection.findOne {trade_id: fill.trade_id}, (err, gee)->
        reject err if err

        # TODO This should probably be a new function/RSVP.Promise
        if gee is null
          console.log fill
          # Convert date from API to something we'll match against
          # fill.time = moment( fill.time ).toDate()
          # console.log fill


          collection.insertOne fill, (err, whiz)->
            reject err if err
            db.close()
            resolve fill

        else
          db.close()
          resolve true


module.exports = saveFill
