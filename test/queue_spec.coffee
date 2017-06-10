should = require 'should'

queue = require '../lib/queue'

describe 'queues', ->
  it 'has empty queue', ->
    q = queue()
    should.not.exist q.peek()

  it 'has one item', ->
    q = queue()
    q.enqueue 'a'
    q.peek().should.be.eql 'a'

  it 'can dequeue an item', ->
    q = queue()
    q.enqueue 'a'
    q.enqueue 'b'

    a = q.dequeue()

    a.should.be.eql 'a'

  it 'can batch dequeue items', ->
    q = queue()
    q.enqueue 'a'
    q.enqueue 'b'
    q.enqueue 'c'

    a = q.batch( 2 )

    a.should.be.eql [ 'a', 'b' ]
