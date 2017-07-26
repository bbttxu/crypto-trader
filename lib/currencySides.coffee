{
  keys
  map
  unnest
} = require 'ramda'



arrayify = require './arrayify'

currencySides = ( config )->
  currencies = config.currencies

  addSides = ( product )->
    arrayify( [ product ] )( keys config.currencies[product] )

  unnest map addSides, keys currencies

module.exports = currencySides
