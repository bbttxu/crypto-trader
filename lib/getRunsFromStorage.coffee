###
.____    ._____.                      .__
|    |   |__\_ |______________ _______|__| ____   ______
|    |   |  || __ \_  __ \__  \\_  __ \  |/ __ \ /  ___/
|    |___|  || \_\ \  | \// __ \|  | \/  \  ___/ \___ \
|_______ \__||___  /__|  (____  /__|  |__|\___  >____  >
        \/       \/           \/              \/     \/
###

{
  Promise
} = require 'rsvp'

{
  merge
} = require 'ramda'

mongoConnection = require './mongoConnection'

moment = require 'moment'


###
___________                   __  .__
\_   _____/_ __  ____   _____/  |_|__| ____   ____   ______
 |    __)|  |  \/    \_/ ___\   __\  |/  _ \ /    \ /  ___/
 |     \ |  |  /   |  \  \___|  | |  (  <_> )   |  \\___ \
 \___  / |____/|___|  /\___  >__| |__|\____/|___|  /____  >
     \/             \/     \/                    \/     \/
###

#
#
getRunsFromStorage = ( search )->

  defaults =
    d_price:
      $ne: 0
    n:
      $ne: 0
    d_time:
      $ne: 0

    end:
      $gt: moment().subtract( 24, 'hours' ).valueOf()

  #
  #
  new Promise ( resolve, reject )->
    callback = ( result )->
      resolve result

    onError = ( error )->
      console.log error
      reject error


    #
    #
    mongoConnection().then ( db )->
      db.collection( 'runs' )
        .find( merge defaults, search )
        .toArray()
        .then(callback)
        .catch(onError)


###
___________                             __
\_   _____/__  _________   ____________/  |_  ______
 |    __)_\  \/  /\____ \ /  _ \_  __ \   __\/  ___/
 |        \>    < |  |_> >  <_> )  | \/|  |  \___ \
/_______  /__/\_ \|   __/ \____/|__|   |__| /____  >
        \/      \/|__|                           \/
###

module.exports = getRunsFromStorage
