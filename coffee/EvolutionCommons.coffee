class EvolutionCommons

	constructor: (@game)->
		@phases = ["Evolution", "Food"]
		@cards = [
			#swimming
			{
				number: 8
				traits: ['swimming']
			}
			{
				number: 2
				traits: ['swimming', 'ambushHunting']
			}
			{
				number: 2
				traits: ['swimming', 'vivaporous']
			}
			#carnivorous
			{
				number: 4
				traits: ['carnivorous', 'poisonous']
			}
			{
				number: 4
				traits: ['carnivorous', 'parasite']
			}
			{
				number: 2
				traits: ['carnivorous', 'metamorphosis']
			}
			{
				number: 2
				traits: ['carnivorous', 'flight']
			}
			{
				number: 4
				traits: ['carnivorous', 'communication']
			}
			{
				number: 4
				traits: ['carnivorous', 'highBodyWeight']
			}
			{
				number: 4
				traits: ['carnivorous', 'cooperation']
			}
			{
				number: 4
				traits: [ 'anglerFish' ]
			}
			{
				number: 4
				traits: ['carnivorous', 'hibernationAbility']
			}
			#fat tissue
			{
				number: 2
				traits: ['fatTissue', 'trematode']
			}
			{
				number: 4
				traits: ['fatTissue', 'camouflage']
			}
			{
				number: 4
				traits: ['fatTissue', 'parasite']
			}
			{
				number: 4
				traits: ['fatTissue', 'cooperation']
			}
			{
				number: 4
				traits: ['fatTissue', 'burrowing']
			}
			{
				number: 2
				traits: ['fatTissue', 'intellect']
			}
			{
				number: 4
				traits: ['fatTissue', 'highBodyWeight']
			}
			{
				number: 4
				traits: ['fatTissue', 'sharpVision']
			}
			{
				number: 4
				traits: ['fatTissue', 'grazing']
			}
			#specializationA
			{
				number: 2
				traits: ['specializationA', 'flight']
			}
			{
				number: 2
				traits: ['specializationA', 'metamorphosis']
			}
			{
				number: 2
				traits: ['specializationA', 'intellect']
			}
			#specializationB
			{
				number: 2
				traits: ['specializationB', 'flight']
			}
			{
				number: 2
				traits: ['specializationB', 'vivaporous']
			}
			{
				number: 2
				traits: ['specializationB', 'ambushHunting']
			}
			#others

			{
				number: 4
				traits: ['shell']
			}
			{
				number: 4
				traits: ['inkCloud']
			}
			{
				number: 4
				traits: ['scavenger']
			}
			{
				number: 4
				traits: ['piracy']
			}
			{
				number: 4
				traits: ['running']
			}
			{
				number: 4
				traits: ['tailLoss']
			}
			{
				number: 4
				traits: ['mimicry']
			}
			{
				number: 4
				traits: ['symbiosis']
			}
			{
				number: 4
				traits: ['trematode', 'cooperation']
			}
			{
				number: 4
				traits: ['trematode', 'communication']
			}
		]
		#
		#
		#
		#
		#
		#
		#
		@traits = {
			swimming: {
				canBeEatenBy: (specie, carnivorousSpecie)=>
					return @hasTrait(carnivorousSpecie, "swimming")
			}
			running: {
				attackSuccesful: (specie)->
					return Math.random()>0.5
			}
			mimicry: {

			}
			scavenger: {}
			symbiosis: {}
			piracy: {}
			tailLoss: {}
			communication: {}
			grazing: {}
			highBodyWeight: { cost: 1 }
			hibernationAbility: {}
			poisonous: {}
			cooperation: {}
			burrowing: {}
			camouflage: {
				canBeEatenBy: (specie, carnivorousSpecie)=>
					return @hasTrait(carnivorousSpecie, "sharpVision")
			}
			sharpVision: {}
			carnivorous: { cost: 1 }
			fatTissue: {}
			parasite: { cost: 2 }
			shell: {}
			intellect: { cost: 1 }
			anglerFish: {}
			specializationA: {}
			specializationB: {}
			trematode: { cost: 1 }
			metamorphosis: {}
			inkCloud: {}
			vivaporous: { cost: 1 }
			ambushHunting: {}
			flight: {
				canBeEatenBy: (specie, carnivorousSpecie)->
					return carnivorousSpecie.traits.length < specie.traits.length
			}
		}
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
		cost = 1
		for trait in specie.traits
			traitCost = @traits[trait.shortName].cost
			if traitCost? then cost += traitCost
		return cost

	isFed: (specie)->
		return specie.foodEaten == @foodAmountRequired(specie)

	checkCompatibleEvolution: (specie, card, addSpecie)->
		specie.compatible = true
		return

	checkCompatibleFood: (specie)->
		# can play if
		# - is not fully fed yet
		# - has special trait: grazing, eat and be fat...
		# - is a carnivorous and has not eaten
		specieFed = @isFed(specie)
		if not specieFed and @game.foodAmount > 0
			specie.compatible = true
		else
			specie.compatible = false

		finished = specieFed or @game.foodAmount == 0

		hasCompatibleTrait = false
		for trait in specie.traits
			trait.compatible = false

			switch trait.shortName
				when 'grazing'
					if not trait.used and @game.foodAmount > 0
						trait.compatible = true
				when 'carnivorous'
					if not trait.used and not @isFed(specie)
						trait.compatible = true
				when 'fatTissue'
					if not trait.used and @isFed(specie) and @game.foodAmount > 0
						trait.compatible = true

			hasCompatibleTrait = hasCompatibleTrait or trait.compatible

		finished = finished and not hasCompatibleTrait

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
		if player.finished then return false
		if @game.foodAmount==0 then return true
		for specie in player.species
			if not @isFed(specie)
				return false
		return true

	card: (cardIndex)->
		return @currentPlayer().hand[cardIndex]

	specie: (specieIndex, playerId = @currentPlayerId())->
		return @player(playerId).species[specieIndex]

	# --- Food phase -- #

	feedSpecie: (specieIndex, playerId = @currentPlayerId())->
		specie = @specie(specieIndex, playerId)
		specie.foodEaten++
		@game.foodAmount--
		@checkCompatibleFood(specie)
		@checkPlayerFinishedFood()
		return @nextPlayer()

	setSpecieEatable: (specie, carnivorousSpecie)->
		for trait in specie.traits
			traitDescription = @traits[trait.shortName]
			if traitDescription.canBeEatenBy? and not traitDescription.canBeEatenBy(specie, carnivorousSpecie)
				specie.eatable = false
				return
		specie.eatable = true
		return

	# TODO: the server does not need to update each specie, it only needs to check the specie being eated
	checkEatable: (playerId = @currentPlayerId(), carnivorousSpecie)->
		for player, i in @game.players
			if i != playerId
				for specie in player.species
					@setSpecieEatable(specie, carnivorousSpecie)
		return

	useTrait: (specieIndex, traitIndex, playerId)->
		specie = @specie(specieIndex, playerId)
		trait = specie.traits[traitIndex]
		switch trait.shortName
			when 'carnivorous'
				trait.compatible = false
				@checkEatable(specie)
		return

	# --- Evolution phase -- #
	createSpecie: (player = @currentPlayer())->
		player.species.push({ traits: [], foodEaten: 0} )
		return

	# called when player plays client side, and on server (on "end turn evolution"), but not when others clients receive result (not on "next player evolution")
	addSpecie: (selectedCard)->
		player = @currentPlayer()
		card = player.hand.splice(selectedCard.cardIndex, 1)[0]
		@createSpecie(player)
		if player.hand.length == 0
			player.finished = true
		return @nextPlayer()

	# check if specie has the trait
	hasTrait: (specie, traitShortName)->
		for trait in specie.traits
			if trait.shortName == traitShortName
				return true
		return false

	# pass to next player
	# play trait on specie
	# set player.finished if finished
	addTrait: (specieIndex, selectedCard)->
		player = @currentPlayer()
		trait = player.hand.splice(selectedCard.cardIndex, 1)[0][selectedCard.traitIndex]
		if player.hand.length == 0
			player.finished = true
		@specie(specieIndex).traits.push( { shortName: trait } )
		return @nextPlayer()

	# pass to next player
	# set player.finished
	playerPassedEvolution: ()->
		player = @currentPlayer()
		player.finished = true
		return @nextPlayer()

	# pass to next player
	# set player.finished
	playerPassedFood: ()->
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

	extinctSpecies: ()->
		for player in @game.players
			for specie in player.species
				if not @isFed(specie)
					specie.extinct = true
		@phaseIndex = 0
		return

	clearExtinctedSpecies: ()->
		for player in @game.players
			i = player.species.length-1
			while i>=0
				specie = player.species[i]
				specie.foodEaten = 0
				if specie.extinct
					player.species.splice(i,1)
				i--
		return

	nextPhase: ()->
		@game.phaseIndex = (@game.phaseIndex+1)%@phases.length
		for player in @game.players
			player.finished = false
		switch @phase()
			when "Evolution"
				@extinctSpecies()
				@game.foodAmount = null
				@game.firstPlayerId = (@game.firstPlayerId+1)%@game.players.length
				@game.currentPlayerId = @game.firstPlayerId
		return

module?.exports = EvolutionCommons

angular?.module("EvolutionCommonsService", []).service "EvolutionCommons" , ()->
	this.EvolutionCommons = EvolutionCommons
