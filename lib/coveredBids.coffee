# .__  ._____.                      .__
# |  | |__\_ |______________ _______|__| ____   ______
# |  | |  || __ \_  __ \__  \\_  __ \  |/ __ \ /  ___/
# |  |_|  || \_\ \  | \// __ \|  | \/  \  ___/ \___ \
# |____/__||___  /__|  (____  /__|  |__|\___  >____  >
#              \/           \/              \/     \/

{
  filter
  propEq
  lastIndexOf
  pluck
  takeLast
} = require 'ramda'

otherSide = require './otherSide'


#   _____                    __  .__
# _/ ____\_ __  ____   _____/  |_|__| ____   ____   ______
# \   __\  |  \/    \_/ ___\   __\  |/  _ \ /    \ /  ___/
#  |  | |  |  /   |  \  \___|  | |  (  <_> )   |  \\___ \
#  |__| |____/|___|  /\___  >__| |__|\____/|___|  /____  >
#                  \/     \/                    \/     \/

onlyFilled = filter propEq 'reason', 'filled'

coveredBids = ( bids, direction )->
  sides = pluck 'side', bids

  # console.log sides, 'z', direction
  latestOppositeIndex = lastIndexOf otherSide( direction ), sides
  # console.log latestOppositeIndex, otherSide( direction ), ( bids.length - latestOppositeIndex - 1 )

  dfjk = onlyFilled takeLast ( bids.length - latestOppositeIndex - 1 ), bids

  dfjk

#                                      __
#   ____ ___  _________   ____________/  |_  ______
# _/ __ \\  \/  /\____ \ /  _ \_  __ \   __\/  ___/
# \  ___/ >    < |  |_> >  <_> )  | \/|  |  \___ \
#  \___  >__/\_ \|   __/ \____/|__|   |__| /____  >
#      \/      \/|__|                           \/

module.exports = coveredBids
