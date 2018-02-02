argv = require('minimist')(process.argv.slice(2))._

###
.____    ._____.                      .__
|    |   |__\_ |______________ _______|__| ____   ______
|    |   |  || __ \_  __ \__  \\_  __ \  |/ __ \ /  ___/
|    |___|  || \_\ \  | \// __ \|  | \/  \  ___/ \___ \
|_______ \__||___  /__|  (____  /__|  |__|\___  >____  >
        \/       \/           \/              \/     \/
###


cleanUpTrades = require './lib/cleanUpTrades'

log = require './lib/log'

exit = require './lib/exit'

Redis = require 'ioredis'



###
___________                   __  .__
\_   _____/_ __  ____   _____/  |_|__| ____   ____   ______
 |    __)|  |  \/    \_/ ___\   __\  |/  _ \ /    \ /  ___/
 |     \ |  |  /   |  \  \___|  | |  (  <_> )   |  \\___ \
 \___  / |____/|___|  /\___  >__| |__|\____/|___|  /____  >
     \/             \/     \/                    \/     \/
###


bid = cleanUpTrades
  product_id: argv[0]
  side: argv[1]
  size: argv[2]
  price: argv[3]


channel = "chamber:#{bid.product_id}"
chamberChannel = new Redis()
payload = JSON.stringify bid


log channel, payload

chamberChannel.publish channel, payload

setTimeout exit, 100
# process.exit 1
