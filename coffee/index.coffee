app = require("express")()
http = require("http").Server(app)
EvolutionCommons = require("./EvolutionCommons.js")
io = require('socket.io')(http)
evolution = require('./evolutionController.js')(io)
gameId = 0
evolution.games[0].ec = new EvolutionCommons(evolution.games[0])
socketData = {}

fakeTurn = (game)->
	if game.currentPlayerId != socketsData().playerId
		game = game()
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

goToFoodPhase = (socket, game)->
	action = {}
	switch game.players.length
		when 2
			action.foodAmount = Math.ceil(Math.random()*6)+2
		when 3
			action.foodAmount = Math.ceil(Math.random()*6)*Math.ceil(Math.random()*6)
		when 4
			action.foodAmount = Math.ceil(Math.random()*6)*Math.ceil(Math.random()*6)+2
	socket.to(sData().room).emit "phase food", action
	socket.emit "phase food", action
	return

app.get "/", (req, res) ->
	res.send { connected: true }
	return

io.on "connection", (socket) ->
	console.log "a user connected"

	sData = ()->
		return socketData[socket.id]

	game = ()->
		return sData().game

	ec = ()->		
		return game().ec
	
	socket.on 'disconnect', ()->
		console.log "disconnect"
		if sData()?.gameId? and sData()?.playerId?
			console.log "disconnected: player: " + sData().playerId + ", game: " + sData().gameId
			evolution.games[sData().gameId].players[sData().playerId].connected = false
		if sData()?
			delete sData()
		return


	socket.on "pass phase evolution", (action) ->
		nextPhase = ec().nextPlayer()
		socket.to(sData().room).emit "player passed evolution", action
		socket.emit "player passed evolution", action
		if nextPhase then goToFoodPhase(socket, game())
		return

	socket.on "end turn evolution", (action) ->
		console.log "end turn: " + action
		if ec().isCompatibleEvolution( action.specieIndex, action.cardIndex )
			player = ec().currentPlayer()
			action.card = player.hand[action.cardIndex]
			ec().addTrait(action.specieIndex, action.cardIndex)
			nextPhase = ec().nextPlayer(game())
			socket.to(sData().room).emit "next player evolution", action
			socket.emit "next player evolution", action
			if nextPhase then goToFoodPhase(socket, game())
		else
			socket.emit "evolution error", action
		return


	socket.on "end turn food", (action) ->
		# action: { specie: specieIndex, trait: traitIndex}
		console.log "end turn food: " + action
		# todo check if valid
		game().players[game().currentPlayerId].species[action.specieIndex].foodEaten++
		game().foodAmount--
		action.previousPlayerId = game().currentPlayerId
		nextPhase = evolution.nextPlayer(game())
		action.currentPlayerId = game().currentPlayerId

		socket.to(sData().room).emit "next player food", action
		socket.emit "next player food", action
		
		if nextPhase then goToExtinctionPhase(socket, game())
		return

	socket.on "load game", (data)->
		socketData[socket.id] = {}

		if data.gameId? and data.playerId? and not evolution.games[data.gameId]?.players[data.playerId]?.connected 	# if player exists but was disconnected
			console.log "player existed"
			evolution.games[data.gameId].players[data.playerId].connected = true
			sData().playerId = data.playerId
			sData().gameId = data.gameId
			sData().room = "game"+data.gameId
		else if not (data.gameId? and data.playerId?) 	# player does not exist
			console.log "player did not exist"
			playerId = evolution.getNewPlayerId(gameId)
			sData().playerId = playerId
			sData().gameId = gameId
			evolution.games[gameId].players[playerId].connected = true
			sData().room = "game"+gameId
		else
			console.log "Error: player existed and was connected"
			socket.emit "game error", "A player is already connected on game " + data.gameId + " with the id " + data.playerId + "."
			return

		socket.join(sData().room)
		console.log "load game " + data.gameId + " for player: " + data.playerId

		sData().game = evolution.games[sData().gameId]
		filteredGame = evolution.filterGame(game(), sData().playerId)
		socket.emit "game loaded", { playerId: sData().playerId, gameId: sData().gameId, game: filteredGame }
		return

	return



http.listen 3000, ->
	console.log "listening on *:3000"
	return


