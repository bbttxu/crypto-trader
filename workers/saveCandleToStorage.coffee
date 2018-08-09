# require( 'dotenv' ).config( silent: true )

# console.log process.env

JOB = 'SAVE_CANDLE_TO_STORAGE'

saveCounter = 0


###
.____    ._____.                      .__
|    |   |__\_ |______________ _______|__| ____   ______
|    |   |  || __ \_  __ \__  \\_  __ \  |/ __ \ /  ___/
|    |___|  || \_\ \  | \// __ \|  | \/  \  ___/ \___ \
|_______ \__||___  /__|  (____  /__|  |__|\___  >____  >
        \/       \/           \/              \/     \/
###

kue = require 'kue'

# mongoDb = require '../lib/mongoDb'

queue = kue.createQueue()

{
  values
  pick
  equals
  difference
  gt
} = require 'ramda'

# console.log process.env

mongoose = require 'mongoose'
mongoose.connect 'mongodb://localhost:27017/gdax'

# findOrCreate = require 'mongoose-findorcreate'
findOrCreate = require 'mongoose-find-or-create'
#


{
  Promise
} = require 'rsvp'
mongoose.Promise = Promise


#  console.log mongoose.Promise
# models

schema = mongoose.Schema
  product: String
  granularity: String
  time: String
  low: Number
  high: Number
  open: Number
  close: Number
  volume: Number

schema.plugin findOrCreate
Candle = mongoose.model 'candle', schema

###
___________                   __  .__
\_   _____/_ __  ____   _____/  |_|__| ____   ____   ______
 |    __)|  |  \/    \_/ ___\   __\  |/  _ \ /    \ /  ___/
 |     \ |  |  /   |  \  \___|  | |  (  <_> )   |  \\___ \
 \___  / |____/|___|  /\___  >__| |__|\____/|___|  /____  >
     \/             \/     \/                    \/     \/
###

addCandleToQueue = ( candle )->
  candle.title = values( candle ).join '-'

  queue.create(
    JOB,
    candle
  ).attempts(
    5
  ).backoff(
    { type: 'exponential' }
  ).removeOnComplete( true ).save()


saveCandleToStorage = ( candle, callback )->
  # console.log candle.data
  delete candle.data.title

  findBy = pick ['product', 'granularity', 'time'], candle.data

  importantValues = pick ['open', 'close', 'high', 'low', 'volume']

  # console.log findBy

  Candle.findOne( findBy ).then(
    ( something )->
      unless something

        # Candle.
        new Candle( candle.data ).save().then(
          ( result )->
            console.log 'ADDED', Date.now(), something._id, JSON.stringify result
        )

        # console.log something, candle.data

      if something
        saved = importantValues something
        current = importantValues candle.data
        # console.log something

        unless equals saved, current
          if gt current.volume, saved.volume
            # console.log current.volume, saved.volume

            Candle.findOneAndUpdate( { _id: something._id }, current ).then(
              ( result )->
                console.log 'UPDATED', something._id, JSON.stringify result
            )

    ( nothing )->
      console.log 'nothing', nothing
  ).finally(
    setTimeout callback, 20
  )


process = ->
  queue.process(
    JOB,
    saveCandleToStorage
  )


queue.on 'error', ( error )->
  console.log JOB, 'ERROR', error


###
.____           __               .___         __  .__    .__
|    |    _____/  |_  ______   __| _/____   _/  |_|  |__ |__| ______
|    |  _/ __ \   __\/  ___/  / __ |/  _ \  \   __\  |  \|  |/  ___/
|    |__\  ___/|  |  \___ \  / /_/ (  <_> )  |  | |   Y  \  |\___ \
|_______ \___  >__| /____  > \____ |\____/   |__| |___|  /__/____  >
        \/   \/          \/       \/                   \/        \/     \/
###

module.exports =
  addCandleToQueue: addCandleToQueue
  process: process
