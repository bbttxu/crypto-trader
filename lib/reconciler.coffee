SIZE_ZERO = '0.00000000'

# for each buy,
# go through sells
# and for each buy
# find any sell that is
# - less than the buy price


#   and for that sell
#   - if sell is same size as buy, then
#     - add value
#     - zero out size on buy
#     - zero out size on sell

#   - if sell is smaller size than buy
#     - sell.size is zerod
#     - buy.size is decremented the sell size
#     - value is added

#   - if sell is larger size than buy
#     - value is added for amount of buy.size
#     - sell.size is subtracted the buy.size
#     - buy.size is zerod


###
.____    ._____.                      .__
|    |   |__\_ |______________ _______|__| ____   ______
|    |   |  || __ \_  __ \__  \\_  __ \  |/ __ \ /  ___/
|    |___|  || \_\ \  | \// __ \|  | \/  \  ___/ \___ \
|_______ \__||___  /__|  (____  /__|  |__|\___  >____  >
        \/       \/           \/              \/     \/
###

{
  min
  equals

} = require 'sanctuary'

{
  uniq
  gt
} = require 'ramda'


###
___________                   __  .__
\_   _____/_ __  ____   _____/  |_|__| ____   ____   ______
 |    __)|  |  \/    \_/ ___\   __\  |/  _ \ /    \ /  ___/
 |     \ |  |  /   |  \  \___|  | |  (  <_> )   |  \\___ \
 \___  / |____/|___|  /\___  >__| |__|\____/|___|  /____  >
     \/             \/     \/                    \/     \/
###

toFixed = ( size = 0 )->
  size.toFixed 8


reconciler = ( buy, sell )->
  value = 0

  if gt sell.price, buy.price

    if equals buy.size, sell.size
      # console.log 'halelueah'

      value = ( sell.price - buy.price ) * sell.size

      buy.size = SIZE_ZERO
      sell.size = SIZE_ZERO


    if gt sell.size, buy.size

      incrementalSize = buy.size
      buy.size = SIZE_ZERO

      value = ( sell.price - buy.price ) * incrementalSize

      sell.size = toFixed sell.size - incrementalSize


    if gt buy.size, sell.size

      incrementalSize = sell.size
      sell.size = SIZE_ZERO

      value = ( sell.price - buy.price ) * incrementalSize

      buy.size = toFixed buy.size - incrementalSize



  return [
    buy
  ,
    sell
  ,
    toFixed value
  ]


###
___________                             __
\_   _____/__  _________   ____________/  |_  ______
 |    __)_\  \/  /\____ \ /  _ \_  __ \   __\/  ___/
 |        \>    < |  |_> >  <_> )  | \/|  |  \___ \
/_______  /__/\_ \|   __/ \____/|__|   |__| /____  >
        \/      \/|__|                           \/
###

module.exports = reconciler



