R = require 'ramda'
moment = require 'moment'

module.exports = ( interval )->
  timeSeries = ( doc )->
    time = moment( doc.time ).unix()
    Math.ceil( time / interval )

  ( docs )->
    R.groupBy timeSeries, docs
