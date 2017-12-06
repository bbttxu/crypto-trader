require('dotenv').config( silent: true )
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
  indexOf
  difference
  reject
} = require 'ramda'

RSVP = require 'rsvp'

saveFill = require './lib/saveFill'

moment = require 'moment'

promiseToUpdateCurrency = ( product_id )->

  new RSVP.Promise (resolve, reject)->

    api = new RSVP.Promise (resolve, reject)->
      getFills( product_id ).then ( data )->
        resolve data



    storage = new RSVP.Promise ( resolve, reject )->

      onSuccess = (db)->
        collection = db.collection 'fill'

        # console.log { product_id: product_id }
        collection
          .find( { product_id: product_id } )
          .limit( 100 )
          .sort( created_at: -1 )
          .toArray (err,data)->
            if err
              console.log 'save2 err', err
              reject err

            resolve pluck 'order_id', data

      onError = (fail)->
        console.log 'fail', fail
        reject fail

      mongoConnection().then(onSuccess).catch(onError)

    RSVP.hash({
      api: api
      storage: storage
    }).then( (results)->
      resolve results
    ).catch( (err)->
      reject err
    )



save = ( config ) ->
  currencies = keys config.currencies

  ->
    promises = map promiseToUpdateCurrency, currencies



    RSVP.all( promises ).then ( matches )->
      # console.log matches

      storage = flatten pluck 'storage', matches
      api = flatten pluck 'api', matches

      alreadyInStorage = ( fill )->
        index = indexOf fill.order_id, storage
        # console.log fill.order_id, index, index isnt -1

        index isnt -1



      leftovers = reject alreadyInStorage, api

      # console.log 'adsf', leftovers



      saveThisFill = ( match )->

        wereGood = (result)->

          since = moment( match.created_at ).fromNow( true )
          if result is true
            console.log '$', since, match.product_id, match.side, match.price, match.size, match.price / match.size
          else
            console.log '+', since

        orNot = (result)->
          console.log 'orNot', result
          exit(3)


        saveFill( match ).then( wereGood ).catch(orNot)


      map saveThisFill, leftovers

      unless 0 is leftovers.length
        console.log leftovers.length, 'saved'
      # console.log uniq flatten matches


    # console.log currencies


module.exports = save
