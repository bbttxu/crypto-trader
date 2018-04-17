quantize = ( factor )->
  ( value )->
    Math.round( value * factor ) / factor

module.exports = quantize
