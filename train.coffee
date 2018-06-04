config = require './config'

{
  addMLToQueue
} = require './workers/ml'

shuffle = require('knuth-shuffle').knuthShuffle

{
  map
  keys
  flatten
} = require 'ramda'

currencies = keys config.currencies

granularities = [
  60
  # 300
  # 900
  # 3600
  # 21600
  # 86400
]

currencyGranularities = map ( currency )->
  granularize = ( granularity )->
    currency: currency
    granularity: granularity
    title: "#{currency} #{granularity}"

  map granularize, granularities

map addMLToQueue, shuffle flatten currencyGranularities currencies

# process.exit 1
console.log 'done'
