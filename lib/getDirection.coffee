
getDirection = ( stats, previous = 'unknown' )->
  return 'sell' if stats.last > stats.open
  return 'buy' if stats.last < stats.open
  previous

module.exports = getDirection
