# {
#   keys
#   map
#   unnest
# } = require 'ramda'

# arrayify = require './arrayify'

# productSideLenses = ( config )->
#   addSides = ( product )->
#     arrayify( [ product ] )( keys config.currencies[product] )

#   unnest map addSides, keys config.currencies

# module.exports = productSideLenses
