# should = require 'should'

# correlationCount = require '../lib/correlationCount'

# testData = [
#   246889711,
#   246889716,
#   246889721,
#   246889726,
#   246889731,
#   246889741,
#   246889746,
# ]

# describe 'correlation count', ->
#   it 'no data', ->

#     correlationCount([]).then (value)->
#       value.should.be.eql []


#   it 'finds the frequency of spacing', ->

#     expected = [
#       { count: 4, spacing: 10, percentage: 0.27 },
#       { count: 4, spacing: 5, percentage: 0.27  },
#       { count: 3, spacing: 15, percentage: 0.2  },
#       { count: 2, spacing: 20, percentage: 0.13  },
#       { count: 1, spacing: 30, percentage: 0.07  },
#       { count: 1, spacing: 25, percentage: 0.07  }
#     ]

#     correlationCount(testData).then (value)->
#       value.should.be.eql expected
