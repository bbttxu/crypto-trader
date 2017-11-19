{
  Promise
} = require 'rsvp'

{
  merge
} = require 'ramda'


mongoConnection = require './mongoConnection'



log = require './log'

moment = require 'moment'

#
#
getRunsFromStorage = ( search )->


  defaults =
    d_price:
      $ne: 0
    n:
      $ne: 0
    d_time:
      $ne: 0
    # end:
    #   $gt: moment().subtract( 1, 'week' ).valueOf()

  console.log 'getRunsFromStorage', merge defaults, search


  #
  #
  new Promise ( resolve, reject )->
    callback = ( result )->
      resolve result

    onError = ( error )->
      console.log error
      reject error


    #
    #
    mongoConnection().then ( db )->
      db.collection( 'runs' )
        .find( merge defaults, search )
        .toArray()
        .then(callback)
        .catch(onError)



module.exports = getRunsFromStorage