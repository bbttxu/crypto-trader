###
.__           .__   _____.__  .__  _____
|  |__ _____  |  |_/ ____\  | |__|/ ____\____
|  |  \\__  \ |  |\   __\|  | |  \   __\/ __ \
|   Y  \/ __ \|  |_|  |  |  |_|  ||  | \  ___/
|___|  (____  /____/__|  |____/__||__|  \___  >
     \/     \/                              \/
###

module.exports = ( amount, halflife, elapsed )->
  amount / 2 ** ( elapsed / halflife )