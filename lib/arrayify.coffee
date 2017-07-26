#
# take an array
# take another array
# return original array with all values appended to the first

{
  map
  unnest
} = require 'ramda'

arrayify = ( base )->

  cupcake = ( sprinkle )->
    base.concat sprinkle

  ( sprinkles )->
    map cupcake, sprinkles


module.exports = arrayify
