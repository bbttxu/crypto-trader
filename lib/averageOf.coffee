{
  sum
  pluck
} = require 'ramda'

average = ( key )->
  ( data )->
    sum(
      pluck(
        key,
        data
      )
    ) / data.length


module.exports = average
