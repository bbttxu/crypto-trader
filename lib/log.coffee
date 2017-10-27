moment = require 'moment'

{
  asTree
} = require 'treeify'

log = ( data, showTime = true )->
  console.log moment().valueOf() if showTime is true
  console.log asTree data, true

module.exports = log

