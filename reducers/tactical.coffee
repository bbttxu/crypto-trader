###
.____    ._____.                      .__
|    |   |__\_ |______________ _______|__| ____   ______
|    |   |  || __ \_  __ \__  \\_  __ \  |/ __ \ /  ___/
|    |___|  || \_\ \  | \// __ \|  | \/  \  ___/ \___ \
|_______ \__||___  /__|  (____  /__|  |__|\___  >____  >
        \/       \/           \/              \/     \/
###

md5 = require 'blueimp-md5'

log = require '../lib/log'

{
  view
  set
  lensProp
  lensPath
  mergeDeepLeft
  map
  mapObjIndexed
} = require 'ramda'

ensureSellIsMoreThanBuy = require '../lib/ensureSellIsMoreThanBuy'


###
.____           __               .___         __  .__    .__
|    |    _____/  |_  ______   __| _/____   _/  |_|  |__ |__| ______
|    |  _/ __ \   __\/  ___/  / __ |/  _ \  \   __\  |  \|  |/  ___/
|    |__\  ___/|  |  \___ \  / /_/ (  <_> )  |  | |   Y  \  |\___ \
|_______ \___  >__| /____  > \____ |\____/   |__| |___|  /__/____  >
        \/   \/          \/       \/                   \/        \/     \/
###

initialState =
  advice: {}
  strategic: {}
  frontline: {}
  proposals: {}
  _hash: 'undefinedtacticalhash'


tacticalReducer = ( state, action )->
  if typeof state == 'undefined'
    return initialState

  if 'ADVICE_UPDATE' is action.type
    lens = lensProp 'advice'
    state = set lens, action.advice, state

  if 'FRONTLINE_UPDATE' is action.type
    lens = lensProp 'frontline'
    state = set lens, action.frontline, state

  if 'STRATEGIC_UPDATE' is action.type
    lens = lensProp 'strategic'
    state = set lens, action.strategic, state


  proposals = mergeDeepLeft state.frontline, state.strategic


  newProposals = {}


  oiewoicncndsjksdfewio = ( side, currency )->
    # console.log currency, side

    lens = lensPath [ currency, side ]

    asdf = view lens, proposals

    if asdf
      newProposals = set lens, asdf, newProposals

    # console.log currency, asdf

  mapObjIndexed oiewoicncndsjksdfewio, state.advice
  # log 'proposals'
  # log proposals
  # log map ensureSellIsMoreThanBuy, proposals

  console.log newProposals

  proposalLens = lensProp 'proposals'
  state = set proposalLens, newProposals, state

  hash = md5 JSON.stringify state.proposals
  hashLens = lensProp '_hash'
  state = set hashLens, hash, state

  state


module.exports = tacticalReducer

