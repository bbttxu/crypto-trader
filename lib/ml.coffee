###
.____    ._____.                      .__
|    |   |__\_ |______________ _______|__| ____   ______
|    |   |  || __ \_  __ \__  \\_  __ \  |/ __ \ /  ___/
|    |___|  || \_\ \  | \// __ \|  | \/  \  ___/ \___ \
|_______ \__||___  /__|  (____  /__|  |__|\___  >____  >
        \/       \/           \/              \/     \/
###

{
  Architect
  Trainer
} = require 'synaptic'

{
  map
} = require 'sanctuary'

{
  pick
  dropLast
  takeLast
} = require 'ramda'

shuffle = require( 'knuth-shuffle' ).knuthShuffle

###
___________                   __  .__
\_   _____/_ __  ____   _____/  |_|__| ____   ____   ______
 |    __)|  |  \/    \_/ ___\   __\  |/  _ \ /    \ /  ___/
 |     \ |  |  /   |  \  \___|  | |  (  <_> )   |  \\___ \
 \___  / |____/|___|  /\___  >__| |__|\____/|___|  /____  >
     \/             \/     \/                    \/     \/
###

makeTrainingSet = map pick [ 'input', 'output' ]


minimums =
  log: 100
  # shuffle: false
  error: .005 # default

ml = ( ios )->

  percentageValue = Math.round ios.length * .1

  myNetwork = new Architect.LSTM 4, 9, 5, 1
  # myNetwork = new Architect.LSTM 4, 5, 1
  # myNetwork = new Architect.Perceptron 4, 5, 1
  # myNetwork = new Architect.Perceptron 28, 29, 1
  trainer = new Trainer myNetwork

  data = makeTrainingSet( ios )

  trainingSet = dropLast percentageValue, data

  testSet = takeLast percentageValue, data

  console.log 'start', ios.length, percentageValue

  trainingResults = trainer.train trainingSet, { log: 10000, shuffle: false }
  testResults = trainer.test testSet

  console.log trainingResults, testResults

  if testResults.error < trainingResults.error


    console.log 'SUCCESS!!!', JSON.stringify myNetwork.toJSON()

  else
    console.log 'FAILED!!!!'



###
.____           __               .___         __  .__    .__
|    |    _____/  |_  ______   __| _/____   _/  |_|  |__ |__| ______
|    |  _/ __ \   __\/  ___/  / __ |/  _ \  \   __\  |  \|  |/  ___/
|    |__\  ___/|  |  \___ \  / /_/ (  <_> )  |  | |   Y  \  |\___ \
|_______ \___  >__| /____  > \____ |\____/   |__| |___|  /__/____  >
        \/   \/          \/       \/                   \/        \/     \/
###

module.exports = ml
