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
