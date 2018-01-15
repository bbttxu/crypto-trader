{
  Promise
} = require 'rsvp'

mongoConnection = require './mongoConnection'

saveBidToStorage = ( bid )->

  #
  #
  new Promise ( resolve, reject )->

    #
    #
    mongoConnection().then ( db )->

      db.collection( 'bids' ).insert bid, ( err, whiz )->
        if err
          console.log 'pidids err', err
          reject err

        resolve whiz.ops[0]


module.exports = saveBidToStorage
