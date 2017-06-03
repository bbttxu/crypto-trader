handleFractionalSize = ( bid, minimumSize, randomNumber = Math.random() )->
  ratio = bid.size / minimumSize

  ratio > randomNumber

module.exports = handleFractionalSize
