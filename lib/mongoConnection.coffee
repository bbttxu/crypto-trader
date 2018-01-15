require('dotenv').config( silent: true )

RESET_CALLS = 100

i = 1

persistedMongoConnection = undefined


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
  equals
  __
} = require 'ramda'


###
___________                   __  .__
\_   _____/_ __  ____   _____/  |_|__| ____   ____   ______
 |    __)|  |  \/    \_/ ___\   __\  |/  _ \ /    \ /  ___/
 |     \ |  |  /   |  \  \___|  | |  (  <_> )   |  \\___ \
 \___  / |____/|___|  /\___  >__| |__|\____/|___|  /____  >
     \/             \/     \/                    \/     \/
###

shouldResetOnCounter = ( index )->
  equals(
    0,
    modulo(
      index,
      RESET_CALLS
    )
  )

#
#
mongoConnection = ( name = 'default' )->

  new RSVP.Promise (resolve, reject)->
    ++i

    if shouldResetOnCounter i
      console.log 'RESET MONGODB CONNECTION', RESET_CALLS, i
      persistedMongoConnection.close() if persistedMongoConnection
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

###
___________                             __
\_   _____/__  _________   ____________/  |_  ______
 |    __)_\  \/  /\____ \ /  _ \_  __ \   __\/  ___/
 |        \>    < |  |_> >  <_> )  | \/|  |  \___ \
/_______  /__/\_ \|   __/ \____/|__|   |__| /____  >
        \/      \/|__|                           \/
###

module.exports = mongoConnection
