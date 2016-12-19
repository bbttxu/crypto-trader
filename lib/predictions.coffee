regression = require 'regression'
R = require 'ramda'

matchesToCartesian = require './matchesToCartesian'
pricing = require './pricing'

linearFirst = ( docs, future )->
  last = R.last docs

  unless last
    return {}

  coords = matchesToCartesian( docs )

  equation = regression( 'linear', coords ).equation

  m = equation[0]
  b = equation[1]

  y = ( m * future ) + b

  return pricing.btc y


linearLast = ( docs, future )->
  last = R.last docs

  unless last
    return {}

  coords = matchesToCartesian( docs, true )

  equation = regression( 'linear', coords ).equation

  m = equation[0]
  b = equation[1]

  y = ( m * future ) + b

  return pricing.btc y



module.exports = ( side, future )->


  ( results )->
    last = R.last results

    isMyGoodSide = (value)->
      # console.log 'angle', value
      # console.log last.price
      # console.log side

      if 'sell' is side
        return ( value > last.price )


      if 'buy' is side
        return ( value < last.price )



    equations = {}

    equations.current = pricing.btc last.price

    linearFirstResults = linearFirst( results, future )
    if linearFirstResults and isMyGoodSide linearFirstResults
      equations["linear-first"] = linearFirstResults

    linearLastResults = linearLast( results, future )
    if linearLastResults and isMyGoodSide linearLastResults
      equations["linear-last"] = linearLast( results, future )

    equations
