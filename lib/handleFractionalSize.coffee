###
Handle Fractional Sizes

the actual size of a bid may be lower than the minimum allowable size for that currency pair

if the ratio of that discrepency, actual vs minumum, is greater than a randomly generated value, let it happen
###

handleFractionalSize = ( bid, minimumSize, randomNumber = Math.random() )->

  ( bid.size / minimumSize ) > randomNumber

module.exports = handleFractionalSize
