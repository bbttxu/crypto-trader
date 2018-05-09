###
.____    ._____.                      .__
|    |   |__\_ |______________ _______|__| ____   ______
|    |   |  || __ \_  __ \__  \\_  __ \  |/ __ \ /  ___/
|    |___|  || \_\ \  | \// __ \|  | \/  \  ___/ \___ \
|_______ \__||___  /__|  (____  /__|  |__|\___  >____  >
        \/       \/           \/              \/     \/
###

{
  map
  prop
} = require 'sanctuary'

{
  zip
} =require 'lodash'

{
  unnest
  addIndex
} = require 'ramda'

###
___________                   __  .__
\_   _____/_ __  ____   _____/  |_|__| ____   ____   ______
 |    __)|  |  \/    \_/ ___\   __\  |/  _ \ /    \ /  ___/
 |     \ |  |  /   |  \  \___|  | |  (  <_> )   |  \\___ \
 \___  / |____/|___|  /\___  >__| |__|\____/|___|  /____  >
     \/             \/     \/                    \/     \/
###


minMax = ( numbers )->
  return
    min: Math.min.apply this, numbers
    max: Math.max.apply this, numbers

normalizeFn = ( limits )->
  ( numbers )->
    applyRatio = ( number )->
      ( number - limits.min ) / ( limits.max - limits.min )

    map applyRatio, numbers


fMap = ( functions, values )->
  mapIndexed = addIndex map

  applyStuff = ( value, index )->
    functions[index].call this, value

  mapIndexed applyStuff, values

# denormaliz


normalizeDatum = ( numbers )->
  transposed = unnest zip numbers

  # console.log transposed

  limits = map minMax, transposed
  limitFns = map normalizeFn, limits

  return
    limits: limits
    normalized: fMap limitFns, transposed
    # denormalize:



###
.____           __               .___         __  .__    .__
|    |    _____/  |_  ______   __| _/____   _/  |_|  |__ |__| ______
|    |  _/ __ \   __\/  ___/  / __ |/  _ \  \   __\  |  \|  |/  ___/
|    |__\  ___/|  |  \___ \  / /_/ (  <_> )  |  | |   Y  \  |\___ \
|_______ \___  >__| /____  > \____ |\____/   |__| |___|  /__/____  >
        \/   \/          \/       \/                   \/        \/     \/
###

module.exports = normalizeDatum
