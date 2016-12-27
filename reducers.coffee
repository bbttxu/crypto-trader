R = require 'ramda'
moment = require 'moment'
INTERVAL = 900

initialState = {}

todoApp = (state, action) ->

  if action.type is 'UPDATE_PREDICTION'
    console.log action.prediction

  state

module.exports = todoApp
