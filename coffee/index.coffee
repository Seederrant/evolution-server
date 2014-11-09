app = require("express")()
http = require("http").Server(app)
io = require('socket.io')(http)
evolution = require('./evolutionController.js')(io)
gameId = 0
socketData = {}


app.get "/", (req, res) ->
	res.send { connected: true }
	return

io.on "connection", (socket) ->
	console.log "a user connected"

	fakeTurn = (game)->
		if game.currentPlayerId != socketsocketData[socket.id].playerId
			game = socketData[socket.id].game
			action = {}
			action.previousPlayerId = game.currentPlayerId
			evolution.nextPlayer(game)
			action.currentPlayerId = game.currentPlayerId
			setTimeout( ()->
				socket.emit "player passed", action
				fakeTurn(game)
				return
			, 5000)
		return

	socket.join(socket.room)

	socket.on 'disconnect', ()->
		console.log "disconnect"
		if socketData[socket.id]?.gameId? and socketData[socket.id]?.playerId?
			console.log "disconnected: player: " + socketData[socket.id].playerId + ", game: " + socketData[socket.id].gameId
			evolution.games[socketData[socket.id].gameId].players[socketData[socket.id].playerId].connected = false
		if socketData[socket.id]?
			delete socketData[socket.id]
		return

	socket.on "pass turn", (action) ->
		game = socketData[socket.id].game
		action.previousPlayerId = game.currentPlayerId
		evolution.nextPlayer(game)
		action.currentPlayerId = game.currentPlayerId
		socket.emit "player passed", action
		return

	socket.on "end turn", (action) ->
		console.log "end turn: " + action
		if evolution.areCompatible(action.card, action.specie)
			game = socketData[socket.id].game
			action.previousPlayerId = game.currentPlayerId
			player = game.players[action.previousPlayerId]
			action.card = player.hand[action.cardId]
			player.hand.splice(action.cardId, 1)
			player.species[action.specieId].push(action.card)
			evolution.nextPlayer(game)
			action.currentPlayerId = game.currentPlayerId
			socket.to(socketData[socket.id].room).emit "next player", action
			socket.emit "next player", action
		else
			socket.emit "evolution error", action
		return

	socket.on "load game", (data)->
		socketData[socket.id] = {}

		if data.gameId? and data.playerId? and not evolution.games[data.gameId]?.players[data.playerId]?.connected
			console.log "player existed"
			evolution.games[data.gameId].players[data.playerId].connected = true
			socketData[socket.id].playerId = data.playerId
			socketData[socket.id].gameId = data.gameId
			socketData[socket.id].room = "game"+data.gameId
		else if not (data.gameId? and data.playerId?)
			console.log "player did not exist"
			playerId = evolution.getNewPlayerId(gameId)
			socketData[socket.id].playerId = playerId
			socketData[socket.id].gameId = gameId
			evolution.games[gameId].players[playerId].connected = true
			socketData[socket.id].room = "game"+gameId
		else
			console.log "Error: player existed and was connected"
			socket.emit "game error", "A player is already connected on game " + data.gameId + " with the id " + data.playerId + "."
			return

		console.log "load game " + data.gameId + " for player: " + data.playerId

		socketData[socket.id].game = evolution.games[socketData[socket.id].gameId]
		game = evolution.filterGame(socketData[socket.id].game, socketData[socket.id].playerId)
		socket.emit "game loaded", { playerId: socketData[socket.id].playerId, gameId: socketData[socket.id].gameId, game: game }
		return

	return



http.listen 3000, ->
	console.log "listening on *:3000"
	return


