# should = require 'should'

# checkObsoleteTrade = require '../lib/checkObsoleteTrade'

# describe 'checkObsoleteTrade', ->
#   it 'nullify trade if price has surged past sell prediction', ->

#     proposal =
#       price: '123.45'
#       side: 'sell'

#     price = '123.46'

#     expected = true

#     result = checkObsoleteTrade proposal, price

#     result.should.be.eql expected

#   it 'nullify trade if price is at sell prediction', ->

#     proposal =
#       price: '123.45'
#       side: 'sell'

#     price = '123.45'

#     expected = true

#     result = checkObsoleteTrade proposal, price

#     result.should.be.eql expected

#   it 'returns trade if price is below sell prediction', ->

#     proposal =
#       price: '123.45'
#       side: 'sell'

#     price = '123.44'

#     result = checkObsoleteTrade proposal, price

#     result.should.be.eql false



#   it 'nullify trade if price has dropped below buy prediction', ->

#     proposal =
#       price: '123.45'
#       side: 'buy'

#     price = '123.44'

#     expected = true

#     result = checkObsoleteTrade proposal, price

#     result.should.be.eql expected

#   it 'nullify trade if price is at buy prediction', ->

#     proposal =
#       price: '123.45'
#       side: 'buy'

#     price = '123.45'

#     expected = true

#     result = checkObsoleteTrade proposal, price

#     result.should.be.eql expected

#   it 'returns trade if price is above buy prediction', ->

#     proposal =
#       price: '123.45'
#       side: 'buy'

#     price = '123.46'

#     result = checkObsoleteTrade proposal, price

#     result.should.be.eql false
