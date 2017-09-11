require('dotenv').config( silent: true )

# mongo = require('mongodb').MongoClient
mongoConnection = require('./lib/mongoConnection')

{
  getFills
} = require './lib/gdax-client'

{
  keys
  map
  pluck
  flatten
  uniq
} = require 'ramda'

RSVP = require 'rsvp'

updateCurrency = ( product_id )->

  new RSVP.Promise ( resolve, reject )->
    # getFills( product_id ).then ( data )->
    #   resolve pluck 'order_id', data

    console.log product_id


    onSuccess = (db)->
      # if err
      #   console.log 'err', err
      #   reject err

      # resolve db

      # Persist connection
      # persistedMongoConnection = connection

      # console.log db


      collection = db.collection 'fill'

      console.log collection


      console.log { product_id: product_id }
      collection
        .find( { product_id: product_id } )
        .limit( 100 )
        .toArray (err,data)->
          if err
            console.log 'err', err
            reject err

          console.log data
          # resolve persistedMongoConnection
          resolve pluck 'order_id', data

    onError = (fail)->
      console.log fail
      reject fail


    # resolve product_id
    # otherwise make connection
    mongoConnection().then(onSuccess).catch(onError)
      # if err
      #   console.log 'err', err
      #   reject err

      # resolve db

      # # Persist connection
      # # persistedMongoConnection = connection

      # console.log db


      # collection = db.collection 'fill'

      # console.log { product_id: product_id }
      # collection.find( { product_id: product_id } ).then (data)->
      #   console.log data
      #   # resolve persistedMongoConnection
      #   resolve 'haha'



save = ( config ) ->
  console.log config

  currencies = keys config.currencies

  ->
    promises = map updateCurrency, currencies
    console.log 'save!', promises
    RSVP.all( promises ).then ( matches )->
      console.log matches
      console.log uniq flatten matches


    # console.log currencies


module.exports = save


# R = require 'ramda'
# moment = require 'moment'

# gdax = require './lib/gdax-client'
# saveFill = require './lib/saveFill'

# config = require './config'


# INTERVAL = 100


# throttledDispatchFill = (match, index = 0)->
#   # console.log index
#   wereGood = (result)->

#     since = moment( match.created_at ).fromNow( true )
#     if result is true
#       console.log '$', since, match.product_id, match.side, match.price, match.size, match.price / match.size
#     else
#       console.log '+', since

#   orNot = (result)->
#     console.log 'orNot', result
#     exit(3)


#   sendThrottledDispatchFill = ->

#     saveFill( match ).then( wereGood ).catch(orNot)

#   setTimeout sendThrottledDispatchFill, ( ( index * INTERVAL ) + ( Math.random() * INTERVAL ) )


# saveFills = ( fills )->
#   # console.log fills
#   mapIndexed = R.addIndex R.map
#   mapIndexed throttledDispatchFill, fills

# cantSaveFills = ( fills )->
#   console.log 'cantSaveFills', fills


# getCurrencyFills = ( product_id )->
#   gdax.getFills( product_id ).then( saveFills ).catch( cantSaveFills )


# module.exports = ->
#   R.map getCurrencyFills, R.keys config.currencies
