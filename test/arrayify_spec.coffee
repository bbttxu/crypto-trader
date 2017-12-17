# arrayify = require '../lib/arrayify'

# should = require 'should'


# #
# describe 'arrayify', ->

#   #
#   it 'takes one array, appends another', ->

#     original = [
#       'a'
#       'b'
#     ]

#     second = [
#       'c'
#       'd'
#     ]

#     expected = [
#       [
#         'a'
#         'b'
#         'c'
#       ], [
#         'a'
#         'b'
#         'd'
#       ]
#     ]

#     a = arrayify original

#     result = a second

#     result.should.be.deepEqual expected


#   it 'takes one array, appends another, then another', ->

#     original = [
#       'a'
#       'b'
#     ]

#     second = [
#       'c'
#       'd'
#     ]

#     third = [
#       'e'
#       'f'
#     ]

#     expected = [
#       [
#         'a'
#         'b'
#         'c'
#         'e'
#       ], [
#         'a'
#         'b'
#         'c'
#         'f'
#       ], [
#         'a'
#         'b'
#         'd'
#         'e'
#       ], [
#         'a'
#         'b'
#         'd'
#         'f'
#       ]

#     ]

#     a = arrayify original

#     result = a second

#     b = arrayify result[0]
#     c = arrayify result[1]

#     result2 = b third
#     result3 = c third

#     # console.log result

#     result2.concat(result3).should.be.deepEqual expected

