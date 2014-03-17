Deckhand.app.controller 'NavCtrl', [
  '$scope', '$modal', 'Search', 'Cards','ModalEditor'
  ($scope, $modal, Search, Cards, ModalEditor) ->
    $scope.search = (term) ->
      Search.query(term: term).$promise

    $scope.select = ->
      Cards.show $scope.result._model, $scope.result.id
      $scope.result = null # clears the text field

    $scope.show = Cards.show

    $scope.act = (action) ->
      ModalEditor.act(action)
]
