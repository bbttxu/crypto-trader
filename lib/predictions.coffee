regression = require 'regression'
R = require 'ramda'
moment = require 'moment'

matchesToCartesian = require './matchesToCartesian'
pricing = require './pricing'

linearLast = ( docs, future, base )->

  last = R.last docs

  unless last
    return {}

  coords = matchesToCartesian( docs, true )

  coords.push [ future, null ]

  equation = regression( 'linear', coords )

  R.last( equation.points )[1]


module.exports = ( side, future, key )->
  base = key.split( '-' )[1].toLowerCase()

  ( results )->

    last = R.last results

    isMyGoodSide = (value)->

      if 'sell' is side
        return ( value > last.price )

      if 'buy' is side
        return ( value < last.price )


    equations = {}

    equations.n = results.length

    return equations if results.length <= 3

    linearLastResults = linearLast( results, future, base )

    if linearLastResults and isMyGoodSide(linearLastResults) and not isNaN( linearLastResults )
      equations.linear = linearLastResults
    else
      return a =
        n: results.length


    equations.future = future

    equations.current = pricing[base] last.price

    equations
