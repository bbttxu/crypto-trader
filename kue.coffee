kue = require 'kue'
express = require 'express'
basicAuth = require 'basic-auth-connect'
app = express()
app.use basicAuth('foo', 'bar')
app.use kue.app
app.listen 3000
