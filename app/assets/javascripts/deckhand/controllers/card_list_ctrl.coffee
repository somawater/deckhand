qs = require("querystring")

Deckhand.app.controller 'CardListCtrl', [
  '$scope', 'Model', 'Cards'
  ($scope, Model, Cards) ->
    $scope.cards = Cards.list()

    $scope.cardTemplate = (item) ->
      Deckhand.templatePath + "?" + qs.stringify(
        model: item._model
        type: (if item.id == 'list' then 'index_card' else 'card')
      )
]
