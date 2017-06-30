fs           = require 'fs'
path         = require 'path'
express      = require 'express'
logger       = require 'morgan'
bodyParser   = require 'body-parser'
cookieParser = require 'cookie-parser'
app          = express()

# config
app.set 'views', path.join __dirname, '../../views'
app.set 'view engine', 'pug'

# routing
app.use express.static path.join __dirname, '../../public'
app.all '*', (req, res) ->
	res.render 'index'

# listen
server = app.listen 8080, ->
	console.log ''
	console.log '################################################################'
	console.log ''
	console.log ' starting WEB SERVER on localhost:' + server.address().port
	console.log '   AUTHOR:     yuki540'
	console.log '   REPOSITORY: https://github.com/yuki540net/satella.io'
	console.log ''
	console.log '################################################################'
	console.log ''

##
# web socket
##
io = require('socket.io')(server)
io.sockets.on 'connection', (socket) ->
	
