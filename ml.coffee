# require('dotenv').config( silent: true )

# RSVP = require 'rsvp'
# R = require 'ramda'
# moment = require 'moment'


# currencySideRecent = require './lib/currencySideRecent'
# predictions = require './lib/predictions'
# quantizeData = require './lib/quantizeData'
# correlationCount = require './lib/correlationCount'

# module.exports = ( currencies, store ) ->

#   sides = [
#     'sell',
#     'buy',
#   ]


#   INTERVAL = 7

#   catchError = (foo)->
#     console.log 'caught', foo

#   showResults = (data)->
#     console.log 'done'


#   letsDoCurrencies = ( currency )->
#     addSide = (side)->
#       foo =
#         currency: currency
#         side: side
#         interval: INTERVAL

#     R.map addSide, sides

#   lookups = R.flatten R.map letsDoCurrencies, currencies


#   asdf = (data)->
#     new RSVP.Promise (resolve, reject)->

#       catchProblem = (problem)->
#         reject problem

#       getRegressionResult = (results)->
#         line = regression results
#         resolve line

#       intervals = [
#         60,
#         # 60 * 60,
#         # 60 * 60 * 24,
#       ]

#       getPredictions = ( results )->
#         intervalPredictions = ( interval = 60 )->

#           obj = {}
#           future = moment().add( interval, 'second' ).unix()

#           past = moment().subtract( interval, 'second' ).unix()

#           pricePredictions = predictions( data.side, future )
#           obj["#{interval}"] = pricePredictions results
#           obj

#         console.log [ data.currency, data.side ].join('-').toUpperCase()
#         console.log R.mergeAll R.map intervalPredictions, intervals
#         return R.mergeAll R.map intervalPredictions, intervals


#         return R.mergeAll R.map intervalPredictions, intervals

#       showOff = (results)->
#         console.log 'results', results

#       currencySideRecent( data.currency, data.side ).then( getPredictions ).then( showOff )


#   make = ( correlation )->
#     obj = {}
#     key = [ correlation.currency, correlation.side, correlation.interval ].join( '-' ).toUpperCase()
#     obj[key] = asdf(correlation)
#     obj

#   keyed = R.mergeAll R.map make, lookups

#   catchProblem = (problem)->
#     console.log 'problem'
#     console.log problem


#   getResult = ( results )->
#     showObjects = (a, b)->
#       console.log b, a.value

#     R.mapObjIndexed showObjects, results


#   RSVP.hashSettled( keyed ).then( getResult ).catch( catchProblem )
