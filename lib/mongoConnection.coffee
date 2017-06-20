require('dotenv').config( silent: true )

RSVP = require 'rsvp'
mongo = require('mongodb').MongoClient

persistedMongoConnection = undefined

#
#
module.exports = new RSVP.Promise (resolve, reject)->

  # return persisted connection if available
  resolve persistedMongoConnection if undefined isnt persistedMongoConnection

  # otherwise make connection
  mongo.connect process.env.MONGO_URL, (err, connection)->
    reject err if err

    # Persist connection
    persistedMongoConnection = connection

    # resolve connection
    resolve persistedMongoConnection
