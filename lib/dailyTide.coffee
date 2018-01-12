{
  gt
  lt
} = require 'ramda'


dailyTide = ( stats, bid )->
  isFlood = gt stats.latest, stats.open
  if isFlood is true
    if bid.side is 'sell'
      return true

    return false

  isEbb = lt stats.latest, stats.open
  if isEbb
    if bid.side is 'sell'
      return false

    return true

  console.log 'huh?s'
  return true






module.exports = dailyTide
