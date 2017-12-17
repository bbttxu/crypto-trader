# {
#   mapObjIndexed
#   values
#   pluck
#   sum
# } = require 'ramda'

# # Primarily for USD
# defaultCurrency =
#   price: 1


# positionDetermine = ( balances, prices )->

#   if not balances && not prices
#     return {}

#   findPositionForCurrency = ( foo, currency )->

#     result = {}

#     currencyBalance = balances[currency]
#     currencyPrice = prices["#{currency}-USD-SELL"] or defaultCurrency

#     foo.holdUSD = parseFloat( ( currencyPrice.price or 1 ) * currencyBalance.hold ).toFixed( 2 )
#     foo.balanceUSD = parseFloat( ( currencyPrice.price or 1 ) * currencyBalance.balance ).toFixed( 2 )

#     foo

#   current = mapObjIndexed findPositionForCurrency, balances

#   sumTotals = ( individualTotals )->
#     individualValues = values individualTotals
#     total =
#       holdUSD: sum pluck 'holdUSD', individualValues
#       balanceUSD: sum pluck 'balanceUSD', individualValues

#   current.total = sumTotals current
#   current.total.totalUSD = current.total.holdUSD + current.total.balanceUSD

#   # return
#   current

# module.exports = positionDetermine
