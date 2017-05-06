{ groupWith } = require 'ramda'

isAdjacent = (datum1, datum2)->
  datum1.side is datum2.side

module.exports = ( data )->
  return groupWith isAdjacent, data
