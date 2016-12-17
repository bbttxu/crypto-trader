require('dotenv').config( silent: true )

mongo = require('mongodb').MongoClient
R = require 'ramda'
RSVP = require 'rsvp'
moment = require 'moment'

pricing = require './pricing'
aggregate = require './aggregate'
pulse = require './pulse'

smallPotatoes = (doc)->
  doc.volume is 0 or doc.delta is 0

module.exports = ( product, side, interval = 60 )->
  ago = moment().subtract( 1, 'day' )

  search =
    product_id: product
    side: side
    time:
      $gte: ago.toISOString()

  # console.log search

  timeSeries = (doc)->
    interval = interval
    time = moment( doc.time ).unix()
    # console.log time, doc.time, interval, Math.ceil( time / interval )

    Math.ceil( time / interval )


  new RSVP.Promise (resolve, reject)->
    mongo.connect process.env.MONGO_URL, (err, db)->
      reject err if err

      collection = db.collection 'matches'

      foo = collection.find( search ).toArray (err, docs)->
        db.close()


        grouped = R.groupBy timeSeries, docs

        # console.log grouped/

        aggregated = R.mapObjIndexed aggregate, grouped

        # console.log aggregated

        volumes = ( R.pluck 'volume', R.values aggregated ).sort()
        prices = ( R.pluck 'price', R.values aggregated ).sort()

        minVolume = Math.min.apply this, R.takeLast (volumes.length * .01 ), volumes
        minPrice = Math.min.apply this, R.takeLast (prices.length * .01 ), prices

        threshold = pulse
          volume: minVolume
          price: minPrice


        grouped = R.map threshold, aggregated

        removeNoPulses = (doc, value)->
          return false if doc
          parseInt value

        isFalse = (data)->
          data is false

        values = R.values R.mapObjIndexed removeNoPulses, grouped

        resolve R.reject isFalse, values
