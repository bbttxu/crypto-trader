should = require 'should'

normalizeStatInputs = require '../lib/normalizeStatInputs'

describe 'normalizeStatInputs', ->
  it '', ->
    input =
      'open': '130.09000000'
      'high': '166.60000000'
      'low': '120.12000000'
      'volume': '919404.81580132'
      'last': '158.18000000'
      'volume_30day': '16186208.75180845'

    output = [
      0.21450086058519796
      0.8188468158347678
      0.5868364864466198
      1
    ]

    normalizeStatInputs( input ).should.be.eql output
