config = require './config'

saveFills = require('./save2')(config)

setInterval saveFills, (1000 * 60 * 10)
