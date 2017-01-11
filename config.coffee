module.exports =
  default:
    interval:
      units: 'seconds'
      value: '300'


  currencies:
    # 'BTC-USD':
    #   sell: {}
    #   buy: {}

    # 'LTC-USD':
    #   sell: {}
    #   buy: {}

    'ETH-USD':
      sell: {}
      buy: {}

    'ETH-BTC':
      sell: {}
      buy: {}

    # 'LTC-BTC':
    #   sell: {}
    #   buy: {}


  # for reporting purposes
  reporting:
    frequency: '23 hours'
    timescales: [
      '24 hours'
      '7 days'
      '4 weeks'
    ]

