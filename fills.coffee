config = require './config'

saveFills = require('./save2')(config)

saveFills()
# setInterval saveFills, (1000 * 60 * 10)
