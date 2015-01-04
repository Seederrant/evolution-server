app = require("express")()
http = require("http").Server(app)
EvolutionCommons = require("./EvolutionCommons.js")
io = require('socket.io')(http)
evolution = require('./evolutionController.js')(io)
gameId = 0

clone = (a)->
	return JSON.parse(JSON.stringify(a))

createGame = ()->
	evolution.games[0] = {}
	game = evolution.games[0]
	game.ec = new EvolutionCommons(game)

	game.firstPlayerId = 0
	game.currentPlayerId = 0
	game.phaseIndex = 0
	game.deck = cards: []

	#init deck wit cards
	cards = game.deck.cards

	for card in game.ec.cards
		for i in [1 .. card.number]
			cards.push( card.traits )

	shuffle = (o) -> #v1.0
		j = undefined
		x = undefined
		i = o.length

		while i
			j = Math.floor(Math.random() * i)
			x = o[--i]
			o[i] = o[j]
			o[j] = x
		return o

	shuffle( cards )

	game.players = []
	game.players.push( name: 'Edouard' )
	game.players.push( name: 'Jacob' )

	for player in game.players
		player.hand = []
		for i in [1 .. 6]
			player.hand.push(cards.pop())
		player.species = []
		player.connected = false
		player.socketId =  null
	return

createGame()

# gameInit = clone(evolution.games[0])

socketData = {}

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

	validState = (phase, playerId)->
		if not ec().phase() == phase and ec().currentPlayerId == sData().playerId
			emit "evolution error", message: "haloumi!"
			return false
		return true

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
		game.foodAmount = action.foodAmount
		socket.to(sData().room).emit "phase food", action
		socket.emit "phase food", action
		return

	goToExtinctionAndEvolutionPhase = (socket, game)->

		# get random element of array
		random = (array) ->
			return array[Math.floor(Math.random()*array.length)]

		ec().clearExtinctedSpecies()
		
		nCardsRequired = 0

		# compute how much cards each player needs
		for player in game.players
			player.nCardsRequired = player.species.length + 1
			nCardsRequired += player.nCardsRequired

		nCardsDealed = 0
		currentPlayer = game.firstPlayerId
		
		# deal the new cards, one by one
		while nCardsDealed<nCardsRequired and game.deck.cards.length>0
			player = game.players[currentPlayer]
			if player.nCardsRequired>0
				player.hand.push( game.deck.cards.pop() )
				player.nCardsRequired--
				nCardsDealed++
			currentPlayer = (currentPlayer+1)%game.players.length

		# send an array *playersCardNumber* giving the new number of card of the players
		playersCardNumber = []
		for player in game.players
			playersCardNumber.push(player.hand.length)
		
		# send specific data (cards) to each player
		for player in game.players
			action = { hand: player.hand, playersCardNumber: playersCardNumber, cardNumberInDeck: game.deck.cards.length }
			socket.server.to(player.socketId).emit "phase evolution", action
		return

	socket.on 'disconnect', ()->
		console.log "disconnect"
		if sData()?.gameId? and sData()?.playerId?
			console.log "disconnected: player: " + sData().playerId + ", game: " + sData().gameId
			evolution.games[sData().gameId].players[sData().playerId].connected = false
		if sData()?
			delete sData()
		return

	socket.on "pass phase evolution", () ->
		if not validState("Evolution") then return
		nextPhase = ec().playerPassedEvolution()
		socket.to(sData().room).emit "player passed evolution"
		socket.emit "player passed evolution"
		if nextPhase then goToFoodPhase(socket, game())
		return

	socket.on "end turn evolution", (action) ->
		if not validState("Evolution") then return
		console.log "end turn evolution: "
		console.log action

		valid = true
		if action.addSpecie
			nextPhase = ec().addSpecie(action.selectedCard)
		else
			specie = ec().specie( action.specieIndex )
			trait = ec().card( action.selectedCard.cardIndex )[action.selectedCard.traitIndex]
			action.trait = trait
			ec().checkCompatibleEvolution( specie, trait )
			
			if specie.compatible
				nextPhase = ec().addTrait(action.specieIndex, action.selectedCard)	
			else
				action.message = "Error: cards are not compatible."
				socket.emit "evolution error", action
				valid = false

		if valid
			socket.to(sData().room).emit "next player evolution", action
			# socket.emit "next player evolution", action
			if nextPhase then goToFoodPhase(socket, game())
		return


	socket.on "end turn food", (action) ->
		if not validState("Food") then return
		# action: { specie: specieIndex, trait: traitIndex}
		console.log "end turn food: "
		console.log action
		# todo check if valid
		if not ec().isFed(ec().specie(action.specieIndex))
			nextPhase = ec().feedSpecie(action.specieIndex)
			socket.to(sData().room).emit "next player food", action
			if nextPhase then goToExtinctionAndEvolutionPhase(socket, game())
		else
			action.message = "Error: Specie is fed."
			socket.emit "evolution error", action
		return

	socket.on "pass phase food", () ->
		if not validState("Evolution") then return
		nextPhase = ec().playerPassedFood()
		socket.to(sData().room).emit "player passed food"
		socket.emit "player passed food"
		if nextPhase then goToExtinctionAndEvolutionPhase(socket, game())
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
		ec().player(sData().playerId).socketId = socket.id
		filteredGame = evolution.filterGame(game(), sData().playerId)
		socket.emit "game loaded", { playerId: sData().playerId, gameId: sData().gameId, game: filteredGame }
		return

	socket.on "restart game", ()->
		console.log "restart game"
		createGame()
		
		socket.to(sData().room).emit "evolution connect"
		socket.emit "evolution connect"
		return

	socket.on "error", (error)->
		console.log error
		throw error
		return

	return



http.listen 3000, ->
	console.log "listening on *:3000"
	return


