module.exports = (status = 42)->
  console.log 'PROCESS RESTART NOW', status
  process.exit(status)
