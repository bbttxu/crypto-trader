# {
#   equals
#   lensPath
#   view
# } = require 'ramda'

# log = require '../lib/log'

# projection = require '../lib/projections'

# source = undefined

# derived = undefined


# matchesWatcher = ->
#   ( store )->

#     path = [ 'matches', 'ETH-BTC', 'buy', 86 ]

#     state = store.getState()

#     lens = lensPath path

#     data = view lens, state

#     # console.log 'here?', data
#     # log data

#     if data
#       if source
#         unless equals data, source
#           source = data

#           derived = projection source

#           log derived

#       unless source
#         source = data

#         derived = projection source

#         log derived



# module.exports = matchesWatcher

