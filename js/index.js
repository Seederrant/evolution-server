(function() {
  var EvolutionCommons, app, clone, createGame, evolution, gameId, http, io, socketData;

  app = require("express")();

  http = require("http").Server(app);

  EvolutionCommons = require("./EvolutionCommons.js");

  io = require('socket.io')(http);

  evolution = require('./evolutionController.js')(io);

  gameId = 0;

  clone = function(a) {
    return JSON.parse(JSON.stringify(a));
  };

  createGame = function() {
    var card, game, i, k, l, len, len1, m, n, player, ref, ref1, ref2, shuffle;
    evolution.games[0] = {};
    game = evolution.games[0];
    game.ec = new EvolutionCommons(game);
    game.firstPlayerId = 0;
    game.currentPlayerId = 0;
    game.phaseIndex = 0;
    game.deck = [];
    ref = game.ec.cards;
    for (k = 0, len = ref.length; k < len; k++) {
      card = ref[k];
      for (i = l = 1, ref1 = card.number; 1 <= ref1 ? l <= ref1 : l >= ref1; i = 1 <= ref1 ? ++l : --l) {
        game.deck.push(card.traits);
      }
    }
    shuffle = function(o) {
      var j, x;
      j = void 0;
      x = void 0;
      i = o.length;
      while (i) {
        j = Math.floor(Math.random() * i);
        x = o[--i];
        o[i] = o[j];
        o[j] = x;
      }
      return o;
    };
    shuffle(game.deck);
    game.players = [];
    game.players.push({
      name: 'Edouard'
    });
    game.players.push({
      name: 'Jacob'
    });
    ref2 = game.players;
    for (m = 0, len1 = ref2.length; m < len1; m++) {
      player = ref2[m];
      player.hand = [];
      for (i = n = 1; n <= 6; i = ++n) {
        player.hand.push(game.deck.pop());
      }
      player.species = [];
      player.connected = false;
      player.socketId = null;
    }
  };

  createGame();

  socketData = {};

  app.get("/", function(req, res) {
    res.send({
      connected: true
    });
  });

  io.on("connection", function(socket) {
    var ec, fakeTurn, game, goToExtinctionAndEvolutionPhase, goToFoodPhase, sData, validState;
    console.log("a user connected");
    sData = function() {
      return socketData[socket.id];
    };
    game = function() {
      return sData().game;
    };
    ec = function() {
      return game().ec;
    };
    validState = function(phase, playerId) {
      if (!ec().phase() === phase && ec().currentPlayerId === sData().playerId) {
        emit("evolution error", {
          message: "haloumi!"
        });
        return false;
      }
      return true;
    };
    fakeTurn = function(game) {
      var action;
      if (game.currentPlayerId !== socketsData().playerId) {
        game = game();
        action = {};
        action.previousPlayerId = game.currentPlayerId;
        evolution.nextPlayer(game);
        action.currentPlayerId = game.currentPlayerId;
        setTimeout(function() {
          socket.emit("player passed", action);
          fakeTurn(game);
        }, 5000);
      }
    };
    goToFoodPhase = function(socket, game) {
      var action;
      action = {};
      switch (game.players.length) {
        case 2:
          action.foodAmount = Math.ceil(Math.random() * 6) + 2;
          break;
        case 3:
          action.foodAmount = Math.ceil(Math.random() * 6) * Math.ceil(Math.random() * 6);
          break;
        case 4:
          action.foodAmount = Math.ceil(Math.random() * 6) * Math.ceil(Math.random() * 6) + 2;
      }
      game.foodAmount = action.foodAmount;
      socket.to(sData().room).emit("phase food", action);
      socket.emit("phase food", action);
    };
    goToExtinctionAndEvolutionPhase = function(socket, game) {
      var action, currentPlayer, k, l, len, len1, len2, m, nCardsDealed, nCardsRequired, player, playersCardNumber, random, ref, ref1, ref2;
      random = function(array) {
        return array[Math.floor(Math.random() * array.length)];
      };
      ec().clearExtinctedSpecies();
      nCardsRequired = 0;
      ref = game.players;
      for (k = 0, len = ref.length; k < len; k++) {
        player = ref[k];
        player.nCardsRequired = player.species.length + 1;
        nCardsRequired += player.nCardsRequired;
      }
      nCardsDealed = 0;
      currentPlayer = game.firstPlayerId;
      while (nCardsDealed < nCardsRequired && game.deck.length > 0) {
        player = game.players[currentPlayer];
        if (player.nCardsRequired > 0) {
          player.hand.push(game.deck.pop());
          player.nCardsRequired--;
          nCardsDealed++;
        }
        currentPlayer = (currentPlayer + 1) % game.players.length;
      }
      playersCardNumber = [];
      ref1 = game.players;
      for (l = 0, len1 = ref1.length; l < len1; l++) {
        player = ref1[l];
        playersCardNumber.push(player.hand.length);
      }
      ref2 = game.players;
      for (m = 0, len2 = ref2.length; m < len2; m++) {
        player = ref2[m];
        action = {
          hand: player.hand,
          playersCardNumber: playersCardNumber,
          cardNumberInDeck: game.deck.length
        };
        socket.server.to(player.socketId).emit("phase evolution", action);
      }
    };
    socket.on('disconnect', function() {
      var ref, ref1;
      console.log("disconnect");
      if ((((ref = sData()) != null ? ref.gameId : void 0) != null) && (((ref1 = sData()) != null ? ref1.playerId : void 0) != null)) {
        console.log("disconnected: player: " + sData().playerId + ", game: " + sData().gameId);
        evolution.games[sData().gameId].players[sData().playerId].connected = false;
      }
      if (sData() != null) {
        delete sData();
      }
    });
    socket.on("pass phase evolution", function() {
      var nextPhase;
      if (!validState("Evolution")) {
        return;
      }
      nextPhase = ec().playerPassedEvolution();
      socket.to(sData().room).emit("player passed evolution");
      socket.emit("player passed evolution");
      if (nextPhase) {
        goToFoodPhase(socket, game());
      }
    });
    socket.on("end turn evolution", function(action) {
      var nextPhase, specie, trait, valid;
      if (!validState("Evolution")) {
        return;
      }
      console.log("end turn evolution: ");
      console.log(action);
      valid = true;
      if (action.addSpecie) {
        nextPhase = ec().addSpecie(action.selectedCard);
      } else {
        specie = ec().specie(action.specieIndex);
        trait = ec().card(action.selectedCard.cardIndex)[action.selectedCard.traitIndex];
        action.trait = trait;
        ec().checkCompatibleEvolution(specie, trait);
        if (specie.compatible) {
          nextPhase = ec().addTrait(action.specieIndex, action.selectedCard);
        } else {
          action.message = "Error: cards are not compatible.";
          socket.emit("evolution error", action);
          valid = false;
        }
      }
      if (valid) {
        socket.to(sData().room).emit("next player evolution", action);
        if (nextPhase) {
          goToFoodPhase(socket, game());
        }
      }
    });
    socket.on("end turn food", function(action) {
      var nextPhase;
      if (!validState("Food")) {
        return;
      }
      console.log("end turn food: ");
      console.log(action);
      if (!ec().isFed(ec().specie(action.specieIndex))) {
        nextPhase = ec().feedSpecie(action.specieIndex);
        socket.to(sData().room).emit("next player food", action);
        if (nextPhase) {
          goToExtinctionAndEvolutionPhase(socket, game());
        }
      } else {
        action.message = "Error: Specie is fed.";
        socket.emit("evolution error", action);
      }
    });
    socket.on("pass phase food", function() {
      var nextPhase;
      if (!validState("Evolution")) {
        return;
      }
      nextPhase = ec().playerPassedFood();
      socket.to(sData().room).emit("player passed food");
      socket.emit("player passed food");
      if (nextPhase) {
        goToExtinctionAndEvolutionPhase(socket, game());
      }
    });
    socket.on("load game", function(data) {
      var filteredGame, playerId, ref, ref1;
      socketData[socket.id] = {};
      if ((data.gameId != null) && (data.playerId != null) && !((ref = evolution.games[data.gameId]) != null ? (ref1 = ref.players[data.playerId]) != null ? ref1.connected : void 0 : void 0)) {
        console.log("player existed");
        evolution.games[data.gameId].players[data.playerId].connected = true;
        sData().playerId = data.playerId;
        sData().gameId = data.gameId;
        sData().room = "game" + data.gameId;
      } else if (!((data.gameId != null) && (data.playerId != null))) {
        console.log("player did not exist");
        playerId = evolution.getNewPlayerId(gameId);
        sData().playerId = playerId;
        sData().gameId = gameId;
        evolution.games[gameId].players[playerId].connected = true;
        sData().room = "game" + gameId;
      } else {
        console.log("Error: player existed and was connected");
        socket.emit("game error", "A player is already connected on game " + data.gameId + " with the id " + data.playerId + ".");
        return;
      }
      socket.join(sData().room);
      console.log("load game " + data.gameId + " for player: " + data.playerId);
      sData().game = evolution.games[sData().gameId];
      ec().player(sData().playerId).socketId = socket.id;
      filteredGame = evolution.filterGame(game(), sData().playerId);
      socket.emit("game loaded", {
        playerId: sData().playerId,
        gameId: sData().gameId,
        game: filteredGame
      });
    });
    socket.on("restart game", function() {
      console.log("restart game");
      createGame();
      socket.to(sData().room).emit("evolution connect");
      socket.emit("evolution connect");
    });
    socket.on("error", function(error) {
      console.log(error);
      throw error;
    });
  });

  http.listen(3000, function() {
    console.log("listening on *:3000");
  });

}).call(this);
