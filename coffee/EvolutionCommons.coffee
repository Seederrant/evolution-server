class EvolutionCommons

	constructor: (@game)->
		@phases =
			"Evolution": 0
			"Food": 1
			"Extinction": 2
		return

	isPlayerTurn: (playerId)->
		return @currentPlayerId() == playerId

	currentPlayer: ()->
		return @game.players[ @currentPlayerId() ]

	player: (index)->
		return @players()[index]

	currentPlayerId: ()->
		return @game.currentPlayerId
	
	isFed: (specie)->
		return specie.foodEaten == @foodAmountRequired(specie)

	players: ()->
		return @game.players

	isCompatibleEvolution: (specie, card)->
		return true

	checkCompatibleFood: (specie)->
		# can play if
		# - is not fully fed yet
		# - has special trait: grazing, eat and be fat...
		# - is a carnivorous and has not eaten
		
		if not isFed(specie)
			specie.compatible = true

		fullyFed = false

		for trait in specie.traits
			if trait.shortName == 'grazing' and not trait.used
				trait.compatible = true
				break
			if trait.shortName == 'carnivorous' and not trait.used and not isFed(specie)
				trait.compatible = true
				break
			if trait.shortName == 'fatTissue' and not trait.used and isFed(specie)
				trait.compatible = true
				break

			fullyFed = fullyFed or not trait.compatible

		specie.fullyFed = fullyFed
		return

	card: (cardIndex)->
		return @currentPlayer().hand[cardIndex]

	specie: (specieIndex, playerId = @currentPlayerId())->
		return @player(playerId).species[specieIndex]

	feedSpecie: (specieIndex, playerId = @currentPlayerId())->
		specie = @specie(specieIndex, playerId)
		specie.foodEaten++
		@game.foodAmount-- # check
		@checkCompatibleFood(specie)
		return

	addTrait: (specieIndex, cardIndex)->
		player = @currentPlayer()
		card = player.hand.splice(cardIndex, 1)[0]
		if player.hand.length == 0
			player.finished = true
		@specie(specieIndex).traits.push(card)
		return

	passPlayerEvolution: ()->
		$scope.players[data.previousPlayerId].finished = true
		next
		return

	# check if the phase is finished (all players have finished) and return true if we go to next phase
	# set currentPlayerId
	nextPlayer: ()->
		i = 0
		while true
			@game.currentPlayerId = (++@game.currentPlayerId)%@game.players.length
			i++
			break unless not @player(@game.currentPlayerId).finished and i == @players.length 
		if i == @players.length
			nextPhase()
			return true
		return false

	nextPhase: ()->
		nextPhaseId = (@phases[@game.phase]+1)%@phases.length
		for name, phaseId of @phases
			if phaseId == nextPhaseId
				@game.phase == name
		for player in @game.players
			player.finished = false
		if @game.phase == "Evolution"
			@game.firstPlayer = (++@game.firstPlayer)%@game.players.length
			@game.currentPlayerId = @game.firstPlayer
		return



module?.exports = EvolutionCommons

angular?.module("EvolutionCommonsService", []).service "EvolutionCommons" , ()->
	this.EvolutionCommons = EvolutionCommons
