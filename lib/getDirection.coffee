
getDirection = ( stats, previous = 'unknown' )->
  return 'sell' if stats.latest > stats.open
  return 'buy' if stats.latest < stats.open
  previous

module.exports = getDirection
