# {
#   prop
# } = require 'ramda'

# log = require './log'

# module.exports = ( bidState )->

#   # return false

#   n = prop 'n_runs', bidState
#   r = prop 'n_runs_ratio', bidState

#   result = n > 10 and r > 5

#   if result
#     return true

#   console.log "decisioner needs #{(10 - n )} runs and ratio > #{r}"
#   false
