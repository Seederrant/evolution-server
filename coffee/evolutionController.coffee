module.exports = (io) ->
	games: [
		firstPlayerId: 0 				# the first player to play in the phase, increments when switching to Evolution phase
		currentPlayerId: 0
		phaseIndex: 0
		deck: { number: 40 }
		players: [ 
			{
				connected: false
				socketId: null
				name: 'Edouard', 
				hand: [ { shortName:"intellect" }, { shortName:"carnivorous", cost: 1 }, { shortName:"vivaporous", cost: 1 }, { shortName:"tailLoss"} ],
				species: [
					{
						traits: [],
						foodEaten: 0
					}
					{
						traits: [ { name:"intellect", shortName:"intellect" }, { name:"carnivorous", cost: 1, shortName:"carnivorous"} ],
						foodEaten: 0
					}
				]
			},
			{
				connected: false
				socketId: null
				name: 'Jacob', 
				hand: [ { shortName:"intellect" }, { shortName:"carnivorous", cost: 1 }, { shortName:"tailLoss"} ],
				species: [
					{
						traits: [],
						foodEaten: 0
					}
					{
						traits: [ { name:"tailLoss", shortName:"tailLoss" }, { name:"vivaporous", cost:1, shortName:"vivaporous"} ]
						foodEaten: 0
					}
				]
			},
			# {
			# 	connected: false
			# 	name: 'Charlotte',
			# 	hand: [ { shortName:"carnivorous" }, { shortName:"vivaporous" } ],
			# 	species: [ [], [ { name:"tailLoss", shortName:"tailLoss" } ] ]
			# } 
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
			phaseIndex: game.phaseIndex
			deck: game.deck
			foodAmount: game.foodAmount
			firstPlayerId: game.firstPlayerId
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

