{
  forEach
  last
  head
  reject
  sort
} = require 'ramda'

moment = require 'moment'


diff = ( first, second )->
  first - second


intervaler = ( intervalsArray )->
  intervals = sort diff, intervalsArray


  ( timestamp, now = moment().unix() )->

    difference = now - timestamp

    lessThanButGreater = ( interval )->
      difference > interval


    head reject lessThanButGreater, intervals





module.exports = intervaler
