# normalizeStatsInputs.coffee

should = require 'should'

normalizeStatsInputs = require '../lib/normalizeStatsInputs'

describe 'normalizeStatsInputs', ->
  it 'alpha key sort', ->
    input =
      def:
        'open': '130.09000000'
        'high': '166.60000000'
        'low': '120.12000000'
        'volume': '919404.81580132'
        'last': '158.18000000'
        'volume_30day': '16186208.75180845'

      abc:
        'open': '2130.09000000'
        'high': '2166.60000000'
        'low': '2120.12000000'
        'volume': '2919404.81580132'
        'last': '2158.18000000'
        'volume_30day': '216186208.75180845'

    output = [
      0.21450086058520332
      0.8188468158347662
      1
      0.4051236430839483
      0.21450086058519796
      0.8188468158347678
      0.5868364864466198
      1
    ]

    normalizeStatsInputs( input ).should.be.eql output

