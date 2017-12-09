require('dotenv').config( silent: true )

###
.____    ._____.                      .__
|    |   |__\_ |______________ _______|__| ____   ______
|    |   |  || __ \_  __ \__  \\_  __ \  |/ __ \ /  ___/
|    |___|  || \_\ \  | \// __ \|  | \/  \  ___/ \___ \
|_______ \__||___  /__|  (____  /__|  |__|\___  >____  >
        \/       \/           \/              \/     \/
###

RSVP = require 'rsvp'
mongo = require('mongodb').MongoClient

{
  modulo
} = require 'ramda'


i = 1

persistedMongoConnection = undefined


#
#
module.exports = ( name = 'default' )->

  new RSVP.Promise (resolve, reject)->
    ++i

    if 0 is modulo i, 100
      persistedMongoConnection.close()
      persistedMongoConnection = undefined

    # return persisted connection if available
    resolve persistedMongoConnection if persistedMongoConnection

    # otherwise make connection
    mongo.connect process.env.MONGO_URL, (err, connection)->
      reject err if err

      # Persist connection
      persistedMongoConnection = connection

      # resolve connection
      resolve connection
