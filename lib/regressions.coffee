regression = require 'regression'
R = require 'ramda'
moment = require 'moment'


docsToCartesian = (doc)->
  x = moment( doc.time ).unix()
  y = parseFloat doc.price

  [ x, y ]

makeStats = (docs)->
  equations =
    'linear-first': ( regression( 'linear', matchesToCartesian( docs ) ).equation )
    'linear-last': ( regression( 'linear', matchesToCartesian( docs, true ) ).equation )

module.exports = makeStats
