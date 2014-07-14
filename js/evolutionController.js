// Generated by CoffeeScript 1.7.1
(function() {
  module.exports = function(io) {
    return {
      phase: "Evolution",
      deck: {
        number: 40
      },
      players: [
        {
          name: 'Edouard',
          hand: [
            {
              shortName: "intellect"
            }, {
              shortName: "carnivorous"
            }, {
              shortName: "vivaporous"
            }, {
              shortName: "tailLoss"
            }
          ],
          species: [
            [], [
              {
                name: "intellect",
                shortName: "intellect"
              }, {
                name: "carnivorous",
                cost: 1,
                shortName: "intellect"
              }
            ]
          ]
        }, {
          name: 'Jacob',
          cardNumber: 5,
          species: [
            [], [
              {
                name: "tailLoss",
                shortName: "tailLoss"
              }, {
                name: "vivaporous",
                cost: 1,
                shortName: "vivaporous"
              }
            ]
          ]
        }, {
          name: 'Charlotte',
          cardNumber: 2,
          species: [
            [], [
              {
                name: "tailLoss",
                shortName: "tailLoss"
              }
            ]
          ]
        }
      ],
      areCompatible: function(card, specie) {
        return true;
      }
    };
  };

}).call(this);

//# sourceMappingURL=evolutionController.map