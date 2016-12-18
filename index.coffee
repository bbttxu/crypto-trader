R = require 'ramda'

config = require './config'

ml = require './ml'


foo = ->
  ml( R.keys config.currencies )

foo()
setInterval foo, 60 * 1000
