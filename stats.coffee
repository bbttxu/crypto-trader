config = require './config'

R = require 'ramda'
moment = require 'moment'
RSVP = require 'rsvp'
# percentage = require 'to-percentage'

pricing = require './lib/pricing'
currencyFormatter = require './lib/currencyFormatter'
gdax = require './lib/gdax-client'
getFills = require './lib/getFills'

bySide = ( fill )->
  fill.side


getFillWorth = ( fill )->
  multiplier = 1.0

  if 'buy' is fill.side
    multiplier = -1.0

  parseFloat( fill.size ) * parseFloat ( fill.price ) * multiplier


getCurrencyFills = ( product_id )->
  new RSVP.Promise (resolve, reject)->
    base = product_id.split('-')[1].toLowerCase()


    tabulateFills = ( fills )->

      notWithinLast = ( timeframe )->

        parts = timeframe.split(' ')

        ago = moment().subtract( parts[0], parts[1] )

        tooOld = ( doc )->
          moment( doc.created_at ).isBefore ago


        inTimeFrame = R.reject tooOld, fills

        sum = R.sum R.map getFillWorth, inTimeFrame

        grouped = R.groupBy R.prop('side'), inTimeFrame

        sells = grouped.sell or []
        buys = grouped.buy or []

        min = Math.min sells.length, buys.length
        min = 10
        # console.log min

        sellsWorth = R.map getFillWorth, sells
        buysWorth = R.map getFillWorth, buys


        sellsSum = R.sum sellsWorth.sort()
        buysSum = Math.abs R.sum buysWorth.sort()

        # console.log sellsSum, buysWorth


        percentage = 0
        if 0 isnt sellsSum and 0 isnt buysSum
          percentage = ( sellsSum / buysSum ) - 1


        obj = {}
        obj[timeframe] =
          sum: sum
          percentage: percentage

        obj


      values = {}
      values = R.mergeAll R.map notWithinLast, config.reporting.timescales
      # values.all = R.sum R.map getFillWorth, fills


      obj = {}
      obj[product_id] = values
      # console.log obj

      resolve obj



    noFills = ( err )->
      console.log 'noFills', err

    getFills( product_id ).then( tabulateFills ).catch( noFills )


promises = R.map getCurrencyFills, R.keys config.currencies




condenseInfo = (value, product)->
  formatter = currencyFormatter product


  condenseOneInfo = (value, key)->
    sum = formatter value.sum
    sum


  timeframeData = ( R.values R.mapObjIndexed condenseOneInfo, value ).join '/'
  "#{product}: #{timeframeData}"




RSVP.all(promises).then (results)->

  # Sort Array by highest values
  highestValue = (doc)->
    R.values(R.values(doc)[0])[0].sum


  prices = ( R.values R.mapObjIndexed condenseInfo, R.mergeAll R.reverse R.sortBy highestValue, results )
  prices.push config.reporting.timescales.join '/'

  console.log prices.join "\n"


process.on 'uncaughtException', (err) ->
  console.log 'Caught exception: ' + err
