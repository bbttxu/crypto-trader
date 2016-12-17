require('dotenv').config( silent: true )

RSVP = require 'rsvp'
R = require 'ramda'

module.exports = ( currencies ) ->

  sides = [
    'sell',
    'buy',
  ]

  quantizeData = require './lib/quantizeData'

  # correlationCount = require './correlationCount'

  INTERVAL = 6

  catchError = (foo)->
    console.log 'caught', foo

  showResults = (data)->
    console.log 'done'


  letsDoCurrencies = ( currency )->
    addSide = (side)->
      foo =
        currency: currency
        side: side
        interval: INTERVAL

    R.map addSide, sides

  lookups = R.flatten R.map letsDoCurrencies, currencies


  asdf = (correlation)->
    new RSVP.Promise (resolve, reject)->

      catchProblem = (problem)->
        reject problem

      getResult = (result)->
        resolve result

      quantizeData( correlation.currency, correlation.side, correlation.interval ).then( getResult ).catch( catchProblem )
      # .then( correlationCount )



  make = ( correlation )->
    obj = {}
    key = [ correlation.currency, correlation.side, correlation.interval ].join( '-' ).toUpperCase()
    obj[key] = asdf correlation
    obj

  keyed = R.mergeAll R.map make, lookups

  # console.log keyed

  catchProblem = (problem)->
    console.log 'problem'
    console.log problem


  getResult = ( results )->
    console.log results
    # showObjects = (a, b)->
    #   console.log b, a.value

    # R.mapObjIndexed showObjects, results

  # console.log keyed
  RSVP.hashSettled( keyed ).then( getResult ).catch( catchProblem )
