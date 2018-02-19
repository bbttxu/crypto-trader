log = require './log'

catchError = ( name )->
  ( error )->
    log name, error

module.exports = catchError
