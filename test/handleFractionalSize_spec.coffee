handleFractionalSize = require '../lib/handleFractionalSize'

should = require 'should'


# Globals
bid =
  size: 0.007

minimumSize = 0.01


#
describe 'handleFractionalSize', ->

  #
  it 'rejects size below randomized size', ->
    handleFractionalSize( bid, minimumSize, 0.8 ).should.not.be.ok

  #
  it 'allows size above randomized size', ->
    handleFractionalSize( bid, minimumSize, 0.6 ).should.be.ok
