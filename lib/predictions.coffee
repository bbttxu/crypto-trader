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

  equation = regression( 'linear', coords ).equation

  m = equation[0]
  b = equation[1]

  y = ( m * future ) + b

  return y


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

    equations.current = pricing[base] last.price

    linearLastResults = linearLast( results, future, base )
    if linearLastResults and isMyGoodSide(linearLastResults) and not isNaN( linearLastResults )
      equations.linear = linearLastResults


    equations
