intervaler = require '../lib/intervaler'

should = require 'should'

# Globals
intervals = [
  86
  864
  8640
]


#
describe 'intervaler', ->

  #
  it 'matches less than first', ->

    a = intervaler( intervals )

    expected = 86

    result = a( 83, 86 )

    result.should.be.equal expected


  #
  it 'matches next than first if equal to first', ->

    a = intervaler( intervals )

    expected = 86

    result = a( 0, 85 )

    result.should.be.equal expected


  #
  it 'matches second than first if equal to first', ->

    a = intervaler( intervals )

    expected = 864

    result = a( 0, 864 )

    result.should.be.equal expected


  #
  it 'matches second than first if equal to first', ->

    a = intervaler( intervals )

    expected = 8640

    result = a( 900, 8640 )

    result.should.be.equal expected
