# should = require 'should'

# projection = require '../lib/projections'

# describe 'projections', ->
#   it 'should calculate positive trend', ->

#     results = [
#       price: '7.90000000'
#       time: '2016-12-18T18:29:10.000000Z'
#     ,
#       price: '7.90000000'
#       time: '2016-12-18T18:29:20.000000Z'
#     ,
#       price: '8.00000000'
#       time: '2016-12-18T18:29:30.000000Z'
#     ,
#       price: '8.00000000'
#       time: '2016-12-18T18:29:40.000000Z'
#     ,
#       price: '7.95000000'
#       time: '2016-12-18T18:29:50.000000Z'
#     ]

#     result = projection results

#     expected =
#       m: 0.000732421875
#       b: -1085504.0885742188
#       n: 5

#     result.should.be.eql expected

#   it 'should return nothing on negative trend', ->

#     results = [
#       price: '8.00000000'
#       time: '2016-12-18T18:29:10.000000Z'
#     ,
#       price: '8.00000000'
#       time: '2016-12-18T18:29:20.000000Z'
#     ,
#       price: '7.90000000'
#       time: '2016-12-18T18:29:30.000000Z'
#     ,
#       price: '7.90000000'
#       time: '2016-12-18T18:29:40.000000Z'
#     ,
#       price: '7.95000000'
#       time: '2016-12-18T18:29:50.000000Z'
#     ]

#     result = projection results

#     expected = {
#       m: -0.000732421875
#       b: 1085519.9885742187
#       n: 5
#     }

#     result.should.be.eql expected

#   it 'should return empty on no fills', ->

#     result = projection []

#     expected =
#       n: 0

#     result.should.be.eql expected
