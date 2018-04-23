config = require './config'

{
  addMLToQueue
} = require './workers/ml'

shuffle = require('knuth-shuffle').knuthShuffle

{
  map
  keys
} = require 'ramda'

currencies = keys config.currencies

map addMLToQueue, shuffle currencies
