module.exports = (io) ->
	games: [
		currentPlayerId: 0
		phase: "Evolution"
		deck: { number: 40 }
		players: [ 
			{
				connected: false
				name: 'Edouard', 
				hand: [ { shortName:"intellect" }, { shortName:"carnivorous" }, { shortName:"vivaporous" }, { shortName:"tailLoss"} ],
				species: [ [], [ { name:"intellect", shortName:"intellect" }, { name:"carnivorous", cost:1, shortName:"intellect"} ] ]
			},
			{
				connected: false
				name: 'Jacob', 
				hand: [ { shortName:"intellect" }, { shortName:"carnivorous" }, { shortName:"tailLoss"} ],
				species: [ [], [ { name:"tailLoss", shortName:"tailLoss" }, { name:"vivaporous", cost:1, shortName:"vivaporous"} ] ]
			},
			{
				connected: false
				name: 'Charlotte',
				hand: [ { shortName:"carnivorous" }, { shortName:"vivaporous" } ],
				species: [ [], [ { name:"tailLoss", shortName:"tailLoss" } ] ]
			} 
		]
	]

	getNewPlayerId: (gameId)->
		i=0
		while @games[gameId].players[i].connected
			i++
		return i

	filterGame: (game, id)->
		copy = 
			currentPlayerId: game.currentPlayerId
			phase: game.phase
			deck: game.deck
			players: []
		for player, i in game.players
			if id==i
				copy.players.push(player)
			else
				playerCopy = {}
				playerCopy.connected = player.connected
				playerCopy.name = player.name
				playerCopy.species = player.species
				playerCopy.cardNumber = player.hand.length
				copy.players.push(playerCopy)
		return copy

	areCompatible: (card, specie)->
		return true

	nextPlayer: (game)->
		game.currentPlayerId = (++game.currentPlayerId)%game.players.length
		return