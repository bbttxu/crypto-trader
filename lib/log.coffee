moment = require 'moment'

log = ( ...data )->
  console.log.apply this, [ moment().format() ].concat data

module.exports = log

