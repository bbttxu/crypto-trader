module.exports = ->
  self = this
  items = []

  self.enqueue = (item) ->
    if 'undefined' is typeof items
      items = []
    items.push item

  self.dequeue = ->
    items.shift()

  self.batch = ( index = 100 )->
    console.log items.length, 'queued' if items.length isnt 0

    items.splice( ( -1 * index ), index )

  self.peek = ->
    items[0]

  self
