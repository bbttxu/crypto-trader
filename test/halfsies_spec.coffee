# halfsies = require '../lib/halfsies'

# should = require 'should'

# describe 'haflsies', ->
#   it 'calculates spread on drop', ->
#     result = halfsies '200.00', '100.00', '1000'
#     result.should.be.eql 500

#   it 'calculates spread on increase', ->
#     result = halfsies '100.00', '200.00', '1000'
#     result.should.be.eql 250

#   it 'calculates minimal size spread on drop', ->
#     result = halfsies '200.00', '100.00', '0'
#     result.should.be.eql 0.001

#   it 'calculates minimal size on increase', ->
#     result = halfsies '200.00', '100.00', '0'
#     result.should.be.eql 0.001
