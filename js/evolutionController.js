(function() {
  module.exports = function(io) {
    return {
      games: [],
      getNewPlayerId: function(gameId) {
        var i;
        i = 0;
        while (this.games[gameId].players[i].connected) {
          i++;
        }
        return i;
      },
      filterGame: function(game, id) {
        var copy, i, j, len, player, playerCopy, ref;
        copy = {
          currentPlayerId: game.currentPlayerId,
          phaseIndex: game.phaseIndex,
          cardNumberInDeck: game.deck.length,
          foodAmount: game.foodAmount,
          firstPlayerId: game.firstPlayerId,
          players: []
        };
        ref = game.players;
        for (i = j = 0, len = ref.length; j < len; i = ++j) {
          player = ref[i];
          if (id === i) {
            copy.players.push(player);
          } else {
            playerCopy = {};
            playerCopy.connected = player.connected;
            playerCopy.name = player.name;
            playerCopy.species = player.species;
            playerCopy.cardNumber = player.hand.length;
            copy.players.push(playerCopy);
          }
        }
        return copy;
      }
    };
  };

}).call(this);
