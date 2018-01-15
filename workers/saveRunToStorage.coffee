JOB = 'SAVE_RUN_TO_STORAGE'

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

mongoDb = require '../lib/mongoDb'

queue = kue.createQueue()


###
___________                   __  .__
\_   _____/_ __  ____   _____/  |_|__| ____   ____   ______
 |    __)|  |  \/    \_/ ___\   __\  |/  _ \ /    \ /  ___/
 |     \ |  |  /   |  \  \___|  | |  (  <_> )   |  \\___ \
 \___  / |____/|___|  /\___  >__| |__|\____/|___|  /____  >
     \/             \/     \/                    \/     \/
###

addRunToQueue = ( run )->
  queue.create(
    JOB,
    run
  ).attempts(
    5
  ).backoff(
    { type: 'exponential' }
  ).save()


saveRunToStorage = ( run, callback )->
  mongoDb( 'runs' ).then(
    ( db )->
      db.insert run.data, ( err, whiz )->
        if err
          console.log 'jrndv err runs', err
          throw err

        console.log JOB, 'saved', whiz.ops[0].product_id, ++saveCounter
        setTimeout callback, 100
  )


process = ->
  queue.process(
    JOB,
    saveRunToStorage
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
  addRunToQueue: addRunToQueue
  process: process
