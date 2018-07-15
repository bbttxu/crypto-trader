require('dotenv').config( silent: true )

# mongo = require('mongodb').MongoClient
RSVP = require 'rsvp'
moment = require 'moment'

mongoConnection = require('../lib/mongoConnection')

COLLECTION_NAME = 'fills'


saveFill = (fill)->
  new RSVP.Promise (resolve, rejectPromise )->
    mongoConnection().then (db)->

      collection = db.collection COLLECTION_NAME

      collection.findOne {trade_id: fill.trade_id}, (err, gee)->
        rejectPromise err if err

        # TODO This should probably be a new function/RSVP.Promise
        if gee is null
          collection.insertOne fill, (err, whiz)->
            rejectPromise err if err
            # db.close()

            resolve fill

        else
          # db.close()
          resolve gee


module.exports = saveFill
