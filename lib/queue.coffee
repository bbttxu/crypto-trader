module.exports = =>
  @items = []

  @enqueue = (item) ->
    @items.push item

  @dequeue = ->
    @items.shift()

  @batch = ( index = 100 )->
    @items.splice( 0, index )

  @peek = ->
    @items[0]

  @
