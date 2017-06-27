# Cull matches that are older than our predictions need

moment = require 'moment'

mongoConnection = require('../lib/mongoConnection')

#
#
cullMatches = ->
  mongoConnection().then (db)->

    matches = db.collection 'matches'

    # anything older than 7 days ago
    query =
      time:
        '$lte': moment().subtract(7, 'days').format()

    matches.deleteMany( query ).then ( message )->
      db.close() # close DB

      nDeleted = message.deletedCount

      console.log nDeleted, 'deleted' if nDeleted > 0


module.exports = cullMatches
