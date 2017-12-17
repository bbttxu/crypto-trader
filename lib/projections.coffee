# {
#   linear
# } = require 'regression'

# matchesToCartesian = require './matchesToCartesian'

# projections = ( data )->

#   coords = matchesToCartesian( data, false )

#   if ( 0 is coords.length )
#     return n: 0


#   if ( 1 is coords.length )
#     return {
#       n: 1
#       m: 0
#       b: coords[0][1]
#       type: 'linear'
#     }

#   projection = linear coords

#   equation =
#     b: projection.equation[1]
#     m: projection.equation[0]
#     n: data.length
#     type: 'linear'

#   return { n: 0 } if equation.n is 0

#   equation

# module.exports = projections
