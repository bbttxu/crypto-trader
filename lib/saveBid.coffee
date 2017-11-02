require('dotenv').config( silent: true )

# mongo = require('mongodb').MongoClient
{
  Promise
} = require 'rsvp'

moment = require 'moment'

mongoConnection = require './mongoConnection'

saveBid = ( bid )->

  #
  #
  new Promise (resolve, reject)->

    #
    #
    mongoConnection().then (db)->
      reject err if err

      db.collection( 'bids' ).insert bid, ( err, whiz )->
        reject err if err
        console.log 'jkahjd', bid, whiz
        resolve whiz.ops[0]


module.exports = saveBid
