# {
#   Promise
# } = require 'rsvp'

# mongoConnection = require './mongoConnection'

# #
# #
# saveRunToStorage = ( run )->

#   #
#   #
#   new Promise ( resolve, reject )->

#     #
#     #
#     mongoConnection().then ( db )->
#       db.collection( 'runs' ).insert run, ( err, whiz )->
#         if err
#           console.log 'jrndv err', err
#           reject err

#         resolve whiz.ops[0]

# module.exports = saveRunToStorage
