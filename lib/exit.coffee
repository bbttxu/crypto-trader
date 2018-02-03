module.exports = ( code = 1 )->
  console.log 'exit', code
  process.exit code
