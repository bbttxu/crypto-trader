require('dotenv').config( silent: true )

RSVP = require 'rsvp'
mongo = require('mongodb').MongoClient

memoize = require 'lodash.memoize'

# persistedMongoConnection = undefined

#
#

module.exports = ( name = 'default' )->
  new RSVP.Promise (resolve, reject)->

    # return persisted connection if available
    # resolve persistedMongoConnection if persistedMongoConnection

    # otherwise make connection
    mongo.connect process.env.MONGO_URL, (err, connection)->
      reject err if err

      # Persist connection
      persistedMongoConnection = connection

      # resolve connection
      resolve connection
