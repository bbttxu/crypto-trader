RSVP = require 'rsvp'
R = require 'ramda'

module.exports = (data)->
  # console.log data

  new RSVP.Promise (resolve, reject)->

    values = R.values data


    return [] if values.length is 0

    length = values.length

    volume = R.sum( R.pluck 'volume', values ) / length
    delta = R.sum( R.pluck 'delta', values ) / length


    bottomFifty = ( foo )->
      foo.volume < volume and foo.delta < delta

    data = R.reject bottomFifty, data


    timeseries = R.keys R.reject bottomFifty, data

    start = parseInt R.head timeseries
    end = parseInt R.last timeseries


    asdf = (foo)->
      quantizeLine = ( tick )->
        if data[tick] isnt undefined then 1 else 0

      R.map quantizeLine, timeseries

    i = 0
    j = 0

    value = timeseries[0]

    out = []

    for i in [0...timeseries.length]
      prev = timeseries[i-1]
      current = timeseries[i]
      diff = current - prev

      unless diff is 1
        out.push timeseries.slice j, i
        j = i


    geez = (a)->
      first = parseInt R.head a
      last = parseInt R.last a

      [first, last]


    pairs = R.map geez, R.reject R.isEmpty, out

    spacings = []


    return [] if pairs.length <= 2
    for x in [1...pairs.length]
      for y in [x...pairs.length]
        spacings.push pairs[y][0] - pairs[x-1][1]


    counts = R.countBy R.identity, spacings




    asdf = (a, b)->
      obj =
        count: a
        spacing: parseInt b

    def = R.values R.mapObjIndexed asdf, counts


    ghi = R.pluck 'count', def

    ghiMin = Math.min.apply this, ghi
    ghiMax = Math.max.apply this, ghi

    countAverage = ghiMax * 0.5


    belowCountAverage = (foo)->
      foo.count < countAverage

    resolve R.reverse R.sortBy R.prop('count'), R.take 5, R.reject belowCountAverage, def
