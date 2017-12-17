# {
#   Promise
# } = require 'rsvp'

# mongoConnection = require './mongoConnection'

# memoize = require 'lodash.memoize'

# mongoDb = ( database )->

#   #
#   #
#   new Promise ( resolve, reject )->

#     #
#     #
#     mongoConnection().then ( db )->

#       resolve db.collection( database )

# module.exports = memoize mongoDb
