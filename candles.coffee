require( 'dotenv' ).config( silent: true )

{ currencies, granularities } = require './config'

{
  keys
  map
  unnest
  take
  sortBy
  prop
  min
  clamp
  addIndex
} = require 'ramda'

candle = require './lib/candle'

{ addCandleToQueue } = require './workers/saveCandleToStorage'

limiter = require './lib/limiter'

shuffle = require('knuth-shuffle').knuthShuffle

matrix = ( one, two )->
  appendTwo = ( foo, index )->
    appendOne = ( bar, index )->
      [ foo, bar ]
    map appendOne, two

  shuffle unnest map appendTwo, one


enqueue = ( param )->
  console.log param, 'enqueu param'
  limiter.schedule(
    candle,
    param[0],
    param[1]

  # )
  # ).then(
  #   ( result )->

  #     console.log result
  #     result
  ).then(
    ( result )->
      applyParams = ( item )->
        product: param[0]
        granularity: param[1]
        time: item[0]
        low: item[1]
        high: item[2]
        open: item[3]
        close: item[4]
        volume: item[5]

      map applyParams, result
  ).then(
    # shuffle
    sortBy prop( 'low' )
  # ).then(
  #   take 10
  ).then(
    map addCandleToQueue

  ).catch(
    console.log
  )

update = ->
  map enqueue, matrix keys( currencies ), granularities




setIntervals = ( granularities, currencies )->
  console.log granularities

  minGranularity = granularities[0]
  ghjk = ( granularity )->
    asdf = ( currency, index )->

      interval = 1000 * min granularities[ index - 1 ] or minGranularity, granularities[ index ]



      doit = ->
        enqueue [ granularity, currency]


      setInterval doit, interval

      # console.log interval
      # console.log [granularity, currency]





    addIndex( map ) asdf, granularities

  map ghjk, currencies





update()
# setInterval update, 300 * 1000


setIntervals granularities, keys currencies
