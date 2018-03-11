###
.____    ._____.                      .__
|    |   |__\_ |______________ _______|__| ____   ______
|    |   |  || __ \_  __ \__  \\_  __ \  |/ __ \ /  ___/
|    |___|  || \_\ \  | \// __ \|  | \/  \  ___/ \___ \
|_______ \__||___  /__|  (____  /__|  |__|\___  >____  >
        \/       \/           \/              \/     \/
###

log = require './log'

leftPad = require 'left-pad'

approximate = require 'approximate-number'
{
  mergeDeepRight
  map
  prop
  reject
  isNil
  mergeAll
  values
  pick
  merge
  mapObjIndexed
  sortBy
  reverse
  forEach
  pluck
  sum
} = require 'ramda'



toKeyedObjects = ( object ) ->
  obj = {}
  obj[object.currency + '-USD'] = getValues object
  obj


getValues = pick( [ 'balance', 'available', 'hold' ] )


ensureFloat = ( float )->
  parseFloat( float or 0 )

multiply = ( one, two )->
  ensureFloat( one ) * ensureFloat( two )


getAmounts = ( pair )->
  # console.log pair
  return
    balance: multiply pair.balance, pair.sell or pair.buy
    hold: multiply pair.hold, pair.sell or pair.buy
    available: multiply pair.available, pair.sell or pair.buy

  pair

###
.____           __               .___         __  .__    .__
|    |    _____/  |_  ______   __| _/____   _/  |_|  |__ |__| ______
|    |  _/ __ \   __\/  ___/  / __ |/  _ \  \   __\  |  \|  |/  ___/
|    |__\  ___/|  |  \___ \  / /_/ (  <_> )  |  | |   Y  \  |\___ \
|_______ \___  >__| /____  > \____ |\____/   |__| |___|  /__/____  >
        \/   \/          \/       \/                   \/        \/     \/
###


sortByBalance = sortBy prop 'balance'

tableify = ( value )->
  leftPad parseFloat( value ).toFixed( 2 ), 8

showApproximateTable = ( value )->
  leftPad approximate( value, { min10k: true, decimal: ',' } ), 8


showStake = ( accounts, pricing )->
  pr = reject isNil, mergeDeepRight pricing, { 'USD-USD': { sell: '1.0', buy: '1.0' }, 'BTC-BTC': { sell: '1.0', buy: '1.0' } }

  # log accounts
  # log pricing


  getAccountBalances = map ( account )->
    source = pick [ 'currency', 'balance', 'hold', 'available' ], account

    usdAmount = 0
    source.usd = 0
    if account
      if account.currency
        if pr
          if pr[ "#{account.currency}-USD" ]
            usdAmount = pr[ "#{account.currency}-USD" ].sell or 0
            source.usd = parseFloat usdAmount * account.balance

    source

  sortByBalance =  sortBy prop 'usd'


  balances = reverse sortByBalance getAccountBalances accounts

  # console.log pricing

  showBalance = ( account )->

    usdAmount = 0

    if account
      if account.currency
        if pr
          if pr[ "#{account.currency}-USD" ]
            usdAmount = pr[ "#{account.currency}-USD" ].sell


    "#{account.currency} #{showApproximateTable( account.balance * usdAmount )} #{tableify( account.balance )} #{tableify( account.hold )} #{tableify( account.available )}"


  log
  console.log ( map showBalance, balances ).join "\n"

  #   # "#{accounts.currency} #{showApproximateTable( accounts.balance )} #{showApproximateTable( accounts.hold )} #{showApproximateTable( accounts.available )}"



  # if accounts and pricing
  #   accts = mergeAll map toKeyedObjects, accounts









  #   usdTotals = map getAmounts, mergeDeepRight pr, accts


  #   deKey = ( value, key )->
  #     value.currency = key
  #     value

  #   vals = values mapObjIndexed deKey, usdTotals



  #   showOff = ( line )->
  #     "#{line.currency} #{showApproximateTable( line.balance )} #{showApproximateTable( line.hold )} #{showApproximateTable( line.available )}"

  #   log ""
  #   log reject isNil, pluck 'balance', vals
  #   # console.log "+TOTALS", ( sum reject isNil, pluck 'balance', vals ).toFixed 2
  #   # console.log ( map showOff, reverse sortByBalance vals ).join "\n"


module.exports = showStake
