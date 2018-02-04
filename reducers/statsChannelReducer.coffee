initialState = {}

statsChannelReducer = ( state, action )->
  if typeof state == 'undefined'
    return initialState

  if 'UPDATE' is action.type
    state[ action.product_id ] = action.stats


  state


module.exports = statsChannelReducer
