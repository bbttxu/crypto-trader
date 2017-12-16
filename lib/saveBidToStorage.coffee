{
  Promise
} = require 'rsvp'

mongoConnection = require './mongoConnection'

saveBidToStorage = ( bid )->
  console.log 'saveBidToStorage', bid
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

        console.log whiz.ops[0]
        resolve whiz.ops[0]


module.exports = saveBidToStorage
