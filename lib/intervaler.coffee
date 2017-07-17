#
# functionals
{
  forEach
  last
  head
  filter
  sort
} = require 'ramda'


#
# used to find current unix
moment = require 'moment'


#
# sort initial arrays, just to be safe
diff = ( first, second )->
  first - second


#
# given an array of integers
intervaler = ( intervalsArray )->
  intervals = sort diff, intervalsArray

  #
  # return the smallest value that is greater than the differenc of the timestamp provided
  # compared against the current timestamp(production), or one provided (testing)
  ( timestamp, now = moment().unix() )->

    # difference provided
    difference = now - timestamp

    # interval is equal to or greater than the difference
    equalToOrGreater = ( interval )->
      difference <= interval


    # return the first interval that is greater than difference
    head filter equalToOrGreater, intervals



#
# export
module.exports = intervaler
