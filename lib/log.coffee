moment = require 'moment'

log = ( data )->
  console.log moment().format(), data

module.exports = log

