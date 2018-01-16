require('dotenv').config( silent: true )

# mongo = require('mongodb').MongoClient
{
  Promise
} = require 'rsvp'

moment = require 'moment'

mongoConnection = require './mongoConnection'

updateBid = ( id, payload )->

  #
  #
  new Promise (resolve, reject)->

    #
    #
    mongoConnection().then (db)->
      reject err if err

      db.collection( 'bids' ).findOne { id: id }, (err, gee)->
        reject err if err

        console.log 'we found a bid with id', id, JSON.stringify gee


        db.collection( 'bids' ).updateOne { id: id }, payload, ( err, whiz )->
          reject err if err
          console.log 'jkahjd dfkkljalkdjlkadfkljlkadjflkajdsflkjklj', bid, whiz
          resolve whiz.ops[0]

      # db.collection( 'bids' ).insert bid, ( err, whiz )->
      #   reject err if err
      #   console.log 'jkahjd', bid, whiz
      #   resolve whiz.ops[0]


module.exports = updateBid
