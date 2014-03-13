Deckhand.app.controller 'SidebarCtrl', [
  '$scope', 'Cards'
  ($scope, Cards) ->
    $scope.cards = Cards.list()
    $scope.remove = Cards.remove
    $scope.show = Cards.show
]
