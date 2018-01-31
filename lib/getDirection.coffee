
getDirection = ( stats, previous = 'unknown' )->
  open = parseFloat stats.open
  last = parseFloat stats.last

  return 'sell' if last > open
  return 'buy' if last < open
  previous

module.exports = getDirection
