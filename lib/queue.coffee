module.exports = ->
  self = this
  items = []

  self.enqueue = (item) ->
    if 'undefined' is typeof items
      items = []
    items.push item

  self.dequeue = ->
    items.shift()

  self.peek = ->
    items[0]

  self
