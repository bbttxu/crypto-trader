{
  Promise
} = require 'rsvp'

# mongoConnection = './lib/mongoConnection'

consolidateRun = require './consolidateRun'

saveRun = ( run, product_id )->
  # console.log run, product_id

  new Promise ( resolve, reject )->
    dispatchStore consolidateRun run, product_id
    resolve consolidateRun run, product_id


module.exports = saveRun
