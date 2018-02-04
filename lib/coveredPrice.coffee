# .__  ._____.                      .__
# |  | |__\_ |______________ _______|__| ____   ______
# |  | |  || __ \_  __ \__  \\_  __ \  |/ __ \ /  ___/
# |  |_|  || \_\ \  | \// __ \|  | \/  \  ___/ \___ \
# |____/__||___  /__|  (____  /__|  |__|\___  >____  >
#              \/           \/              \/     \/

{
  uniq
  equals
  gt
  pluck
} = require 'ramda'

arrayStats = require './arrayStats'

log = require './log'

#   _____                    __  .__
# _/ ____\_ __  ____   _____/  |_|__| ____   ____   ______
# \   __\  |  \/    \_/ ___\   __\  |/  _ \ /    \ /  ___/
#  |  | |  |  /   |  \  \___|  | |  (  <_> )   |  \\___ \
#  |__| |____/|___|  /\___  >__| |__|\____/|___|  /____  >
#                  \/     \/                    \/     \/


coveredPrice = ( bids )->

  sides = uniq pluck 'side', bids

  unless equals( 1, sides.length )
    log 'undefined there is mixed data'
    return undefined

  prices = pluck 'price', bids

  stats = arrayStats prices

  if sides[0] is 'sell'
    return stats.min

  stats.max


#                                      __
#   ____ ___  _________   ____________/  |_  ______
# _/ __ \\  \/  /\____ \ /  _ \_  __ \   __\/  ___/
# \  ___/ >    < |  |_> >  <_> )  | \/|  |  \___ \
#  \___  >__/\_ \|   __/ \____/|__|   |__| /____  >
#      \/      \/|__|                           \/

module.exports = coveredPrice
