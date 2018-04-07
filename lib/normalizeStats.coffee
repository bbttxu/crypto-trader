{
  prop
  map
  init
  pick
  values
  flatten
  tail
} = require 'ramda'

normalizePrices = require './normalizePrices'
normalizeVolumes = require './normalizeVolumes'


normalizeStats = ( stats )->
  console.log 'normalizeStats', normalizeVolumes stats
  stats


module.exports = normalizeStats
