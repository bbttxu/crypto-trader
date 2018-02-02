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


#   _____                    __  .__
# _/ ____\_ __  ____   _____/  |_|__| ____   ____   ______
# \   __\  |  \/    \_/ ___\   __\  |/  _ \ /    \ /  ___/
#  |  | |  |  /   |  \  \___|  | |  (  <_> )   |  \\___ \
#  |__| |____/|___|  /\___  >__| |__|\____/|___|  /____  >
#                  \/     \/                    \/     \/


coveredPrice = ( bids )->

  sides = uniq pluck 'side', bids

  prices = uniq pluck 'price', bids

  # console.log sides, prices

  if equals( 1, sides.length ) and gt( prices.length, 1 )

    edge = if sides[0] is 'sell' then Math.min else Math.max

    return edge.apply this, prices

  undefined

#                                      __
#   ____ ___  _________   ____________/  |_  ______
# _/ __ \\  \/  /\____ \ /  _ \_  __ \   __\/  ___/
# \  ___/ >    < |  |_> >  <_> )  | \/|  |  \___ \
#  \___  >__/\_ \|   __/ \____/|__|   |__| /____  >
#      \/      \/|__|                           \/

module.exports = coveredPrice
