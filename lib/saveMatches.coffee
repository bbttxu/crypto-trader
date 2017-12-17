require('dotenv').config( silent: true )

R = require 'ramda'
mongo = require('mongodb').MongoClient
RSVP = require 'rsvp'
moment = require 'moment'

log = require '../lib/log'

mongoConnection = require('../lib/mongoConnection')

necessaryFields = [
  'side'
  'size'
  'price'
  'product_id'
  'time'
  'trade_id'
  'timestamp'
  'sequence'
]

#
#
saveMatches = ( matches ) ->
  new RSVP.Promise (resolve, reject) ->
    mongoConnection().then (db) ->

      matchesCollection = db.collection 'matches'

      details = R.map R.pick( necessaryFields ), matches

      matchesCollection.insert( details ).then ( whiz ) ->
        resolve details


module.exports = saveMatches
