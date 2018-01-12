{
  gt
  lt
} = require 'ramda'


dailyTide = ( stats, bid )->
  isFlood = gt stats.last, stats.open
  if isFlood is true
    if bid.side is 'sell'
      return true

    console.log 'V tried to buy/other on rise'
    return false

  isEbb = lt stats.last, stats.open
  if isEbb
    if bid.side is 'sell'
      console.log 'V tried to sell/other on sink'
      return false

    return true

  console.log 'huh?s'
  return true






module.exports = dailyTide
