argv = require('minimist')(process.argv.slice(2))
PRODUCT_ID = argv._[0]

{
  stat
} = require './lib/gdax-client'

{
  map
  mapObjIndexed
  values
} = require 'ramda'

{
  all
} = require 'rsvp'

saveStat = require './lib/saveStat'

makeStat = ( rawStat, product_id )->
  rawStat.product_id = product_id
  rawStat


updateStats = ->
  stat( PRODUCT_ID ).then(
    ( result )->
      console.log result, 'result'

      all(
        map(
          saveStat,
          values mapObjIndexed(
            makeStat,
            result
          )
        )
      ).then(
        ( results )->
          console.log results
      ).catch(
        ( error )->
          console.log 'ERROR', error
      )


  ).catch(
    ( err )->
      console.log 'stats err', err
  )

setInterval updateStats, 60 * 1000
updateStats()
