require('dotenv').config( silent: true )

RSVP = require 'rsvp'
mongo = require('mongodb').MongoClient

mongoConnection = undefined

module.exports = new RSVP.Promise (resolve, reject)->

  # return persisted connection if available
  resolve mongoConnection if undefined isnt mongoConnection

  # otherwise make connection
  mongo.connect process.env.MONGO_URL, (err, db)->
    reject err if err

    # Persist connection
    mongoConnection = db

    # resolve connection
    resolve mongoConnection
