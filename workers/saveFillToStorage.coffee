JOB = 'SAVE_FILL_TO_STORAGE'
COLLECTION = 'fills'

counter = 0


###
.____    ._____.                      .__
|    |   |__\_ |______________ _______|__| ____   ______
|    |   |  || __ \_  __ \__  \\_  __ \  |/ __ \ /  ___/
|    |___|  || \_\ \  | \// __ \|  | \/  \  ___/ \___ \
|_______ \__||___  /__|  (____  /__|  |__|\___  >____  >
        \/       \/           \/              \/     \/
###

kue = require 'kue'

mongoDb = require '../lib/mongoDb'

queue = kue.createQueue()

{
  pick
} = require 'ramda'
###
___________                   __  .__
\_   _____/_ __  ____   _____/  |_|__| ____   ____   ______
 |    __)|  |  \/    \_/ ___\   __\  |/  _ \ /    \ /  ___/
 |     \ |  |  /   |  \  \___|  | |  (  <_> )   |  \\___ \
 \___  / |____/|___|  /\___  >__| |__|\____/|___|  /____  >
     \/             \/     \/                    \/     \/
###

addFillToQueue = ( fill )->
  title = fill.trade_id + ' ' + fill.product_id
  fill.title = title
  # console.log fill.trade_id, fill.product_id

  queue.create(
    JOB,
    fill
  ).attempts(
    5
  ).backoff(
    { type: 'exponential' }
  ).removeOnComplete( true ).save()
  fill

onErr = ( error )->
  console.log 'we got a muthafuckin err'
  console.log error
  error


minimumProperties = [
  'trade_id'
  'product_id'
  # 'order_id'
]

saveFillToStorage = ( fill, callback )->
  # console.log '', fill.data
  mongoDb( COLLECTION ).then(
    ( db )->

      # console.log 'about to insert', pick( minimumProperties, fill.data )

      db.findOne pick( minimumProperties, fill.data ), ( err, results )->
        onErr( err ) if err
        if null is results
          # console.log 'know now to insert', pick( minimumProperties, fill.data )
          # console.log results, fill.data
          # console.log pick minimumProperties, fill.data

          db.insert fill.data, ( err, whiz )->
            onErr( err ) if err

            console.log JOB, 'saved', whiz.ops[0].product_id, whiz.ops[0].trade_id, ++counter
            setTimeout callback, 100

        unless null is results
          # console.log 'already saved!', pick( minimumProperties, fill.data )
          callback()
  )


process = ->
  queue.process(
    JOB,
    saveFillToStorage
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
  addFillToQueue: addFillToQueue
  process: process
