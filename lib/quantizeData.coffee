require('dotenv').config( silent: true )

mongo = require('mongodb').MongoClient
R = require 'ramda'
RSVP = require 'rsvp'
moment = require 'moment'

pricing = require './pricing'
pulse = require './pulse'

smallPotatoes = (doc)->
  doc.volume is 0 or doc.delta is 0

module.exports = ( product, side, interval = 60 )->
  ago = moment().subtract( 7, 'day' )

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

        threshold = pulse
          volume: 1
          priceChange: 0.01

        grouped = R.mapObjIndexed threshold, R.groupBy timeSeries, docs

        console.log grouped

        resolve grouped
