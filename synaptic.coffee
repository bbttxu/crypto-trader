# R = require 'ramda'

# moment = require 'moment'

# dataMatches = require './lib/dataMatches'







# dataMatches( 'BTC-USD' ).then ( data )->
#   console.log R.uniq R.pluck 'product_id', data
#   console.log R.uniq R.pluck 'side', data
#   console.log Math.max.apply this, R.pluck 'price', data
#   console.log Math.min.apply this, R.pluck 'price', data
#   console.log moment().format()
