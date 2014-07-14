app = require("express")()
http = require("http").Server(app)
io = require('socket.io')(http)
evolution = require('evolutionController')(io)


app.get "/", (req, res) ->
	res.send { connected: true }
	return

io.on "connection", (socket) ->
	console.log "a user connected"

	socket.on 'disconnect', ()->
		console.log "disconnected"

	socket.on "end turn", (action) ->
		console.log "end turn: " + action

		if evolution.areCompatible(action.card, action.specie)
			io.emit(action, { for: 'everyone' })

	return


http.listen 3000, ->
	console.log "listening on *:3000"
	return


