require('dotenv').config( silent: true )

# mongo = require('mongodb').MongoClient
RSVP = require 'rsvp'
moment = require 'moment'

mongoConnection = require('../lib/mongoConnection')

R = require 'ramda'

uuid = require 'uuid'

moment = require 'moment'


mergeDefaults = ( stat )->
  defaults =
    _id: uuid.v4()
    timestamp: moment().valueOf()

  R.merge defaults, stat


saveStat = ( stat )->
  new RSVP.Promise ( resolve, reject )->
    mongoConnection().then ( db )->

      collection = db.collection 'stats'

      collection.insertOne mergeDefaults( stat ), ( err, whiz )->
        reject err if err
        resolve whiz.ops[0]


module.exports = saveStat
