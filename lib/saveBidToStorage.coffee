{
  Promise
} = require 'rsvp'

mongoDb = require './mongoDb'
# mongoConnection = require './mongoConnection'

saveBidToStorage = ( bid )->

  #
  #
  new Promise ( resolve, reject )->

    #
    #
    mongoDb( 'bids' ).then ( db )->

      db.insert bid, ( err, whiz )->
        if err
          console.log 'pidids err', err
          reject err

        resolve whiz.ops[0]


module.exports = saveBidToStorage
