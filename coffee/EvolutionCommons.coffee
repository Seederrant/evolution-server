class EvolutionCommons

	constructor: (@game)->
		@phases = ["Evolution", "Food", "Extinction"]
		return

	isPlayerTurn: (playerId)->
		return @currentPlayerId() == playerId

	currentPlayer: ()->
		return @game.players[ @currentPlayerId() ]

	player: (index)->
		return @game.players[index]

	currentPlayerId: ()->
		return @game.currentPlayerId
	
	foodAmountRequired: (specie)->
		expensiveTraits = ['carnivorous', 'high-body-weight', 'parasite', 'co-parasite', 'vivaporous' ]
		cost = 1
		for trait in specie.traits
			if trait.shortName in expensiveTraits
				cost += 1
			if trait.shortName == 'parasite'
				cost += 1
		return cost

	isFed: (specie)->
		return specie.foodEaten == @foodAmountRequired(specie)

	checkCompatibleEvolution: (specie, card)->
		return true

	checkCompatibleFood: (specie)->
		# can play if
		# - is not fully fed yet
		# - has special trait: grazing, eat and be fat...
		# - is a carnivorous and has not eaten
		
		if not @isFed(specie)
			specie.compatible = true
		else
			specie.compatible = false

		finished = false

		for trait in specie.traits
			if trait.shortName == 'grazing' and not trait.used
				trait.compatible = true
				break
			if trait.shortName == 'carnivorous' and not trait.used and not @isFed(specie)
				trait.compatible = true
				break
			if trait.shortName == 'fatTissue' and not trait.used and @isFed(specie)
				trait.compatible = true
				break

			finished = finished or not trait.compatible

		specie.finished = finished
		return

	checkPlayerFinishedFood: ()->
		player = @currentPlayer()
		for specie in player.species
			if not specie.finished
				return
		player.finished = true
		return

	canPassFood: ()->
		player = @currentPlayer()
		if @game.foodAmount==0 then return true
		for specie in player.species
			if not @isFed(specie)
				return false
		return true

	card: (cardIndex)->
		return @currentPlayer().hand[cardIndex]

	specie: (specieIndex, playerId = @currentPlayerId())->
		return @player(playerId).species[specieIndex]

	feedSpecie: (specieIndex, playerId = @currentPlayerId())->
		specie = @specie(specieIndex, playerId)
		specie.foodEaten++
		@game.foodAmount--
		@checkCompatibleFood(specie)
		@checkPlayerFinishedFood()
		return @nextPlayer()

	# pass to next player
	# play trait on specie
	# set player.finished if finished
	addTrait: (specieIndex, cardIndex)->
		player = @currentPlayer()
		card = player.hand.splice(cardIndex, 1)[0]
		if player.hand.length == 0
			player.finished = true
		@specie(specieIndex).traits.push(card)
		return @nextPlayer()

	# pass to next player
	# set player.finished
	playerPassedEvolution: ()->
		player = @currentPlayer()
		player.finished = true
		return @nextPlayer()

	# check if the phase is finished (all players have finished) and return true if we go to next phase
	# set currentPlayerId
	nextPlayer: ()->
		i = 0
		players = @game.players
		while i < players.length
			@game.currentPlayerId = (@game.currentPlayerId+1)%players.length
			if not @player(@game.currentPlayerId).finished
				break
			i++
		console.log @game.currentPlayerId
		if i == players.length
			@game.currentPlayerId = @game.firstPlayerId
			@nextPhase()
			return true
		return false

	phase: ()->
		return @phases[@game.phaseIndex]

	nextPhase: ()->
		@game.phaseIndex = (@game.phaseIndex+1)%@phases.length
		for player in @game.players
			player.finished = false
		if @phase() == "Evolution"
			@game.firstPlayerId = (@game.firstPlayerId+1)%@game.players.length
			@game.currentPlayerId = @game.firstPlayerId
		return

module?.exports = EvolutionCommons

angular?.module("EvolutionCommonsService", []).service "EvolutionCommons" , ()->
	this.EvolutionCommons = EvolutionCommons
