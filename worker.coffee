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

mongoDb = require './lib/mongoDb'

queue = kue.createQueue()


###
___________                   __  .__
\_   _____/_ __  ____   _____/  |_|__| ____   ____   ______
 |    __)|  |  \/    \_/ ___\   __\  |/  _ \ /    \ /  ___/
 |     \ |  |  /   |  \  \___|  | |  (  <_> )   |  \\___ \
 \___  / |____/|___|  /\___  >__| |__|\____/|___|  /____  >
     \/             \/     \/                    \/     \/
###

saveBidToStorage = ( bid, callback )->
  console.log 'SAVE_BID_TO_STORAGE saving', bid.data.product_id, bid.data.reason, bid.data.id
  mongoDb( 'bids' ).then(
    ( db )->
      db.insert bid.data, ( err, whiz )->
        if err
          console.log 'pidids err', err
          throw err

        console.log 'SAVE_BID_TO_STORAGE  saved', whiz.ops[0].product_id, whiz.ops[0].reason, whiz.ops[0].id, ++saveCounter
        setTimeout callback, 1000
  )


###
.____           __               .___         __  .__    .__
|    |    _____/  |_  ______   __| _/____   _/  |_|  |__ |__| ______
|    |  _/ __ \   __\/  ___/  / __ |/  _ \  \   __\  |  \|  |/  ___/
|    |__\  ___/|  |  \___ \  / /_/ (  <_> )  |  | |   Y  \  |\___ \
|_______ \___  >__| /____  > \____ |\____/   |__| |___|  /__/____  >
        \/   \/          \/       \/                   \/        \/     \/
###

queue.process(
  'SAVE_BID_TO_STORAGE',
  saveBidToStorage
)

queue.on 'error', ( error )->
  console.log error
