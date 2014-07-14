module.exports = (io) ->
	phase: "Evolution"
	deck: { number: 40 }
	players: [ 
		{
			name: 'Edouard', 
			hand: [ { shortName:"intellect" }, { shortName:"carnivorous" }, { shortName:"vivaporous" }, { shortName:"tailLoss"} ],
			species: [ [], [ { name:"intellect", shortName:"intellect" }, { name:"carnivorous", cost:1, shortName:"intellect"} ] ]
		},
		{
			name: 'Jacob', 
			cardNumber: 5,
			species: [ [], [ { name:"tailLoss", shortName:"tailLoss" }, { name:"vivaporous", cost:1, shortName:"vivaporous"} ] ]
		},
		{
			name: 'Charlotte',
			cardNumber: 2,
			species: [ [], [ { name:"tailLoss", shortName:"tailLoss" } ] ]
		} 
	]

	areCompatible: (card, specie)->
		return true