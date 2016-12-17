RSVP = require 'rsvp'
R = require 'ramda'

pricing = require './pricing'

module.exports = (data)->
  new RSVP.Promise (resolve, reject)->
    resolve [] if data.length is 0

    length = data.length

    start = parseInt R.head data
    end = parseInt R.last data

    i = 0
    j = 0


    out = []

    for i in [0...data.length]
      prev = data[i-1]
      current = data[i]
      diff = current - prev

      unless diff is 1
        out.push data.slice j, i
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

    totals = R.sum R.values counts

    asdf = (a, b)->
      obj =
        percentage: parseFloat pricing.usd a / totals
        count: a
        spacing: parseInt b

    def = R.values R.mapObjIndexed asdf, counts


    ghi = R.pluck 'count', def

    ghiMin = Math.min.apply this, ghi
    ghiMax = Math.max.apply this, ghi

    countAverage = ghiMax * 0.5

    belowCountAverage = (foo)->
      foo.count < countAverage

    resolve R.reverse R.sortBy R.prop('count'), def
