fs = require 'fs'
template = fs.readFileSync(__dirname + '/dh_table.html', 'utf8')

Deckhand.app.directive 'dhTable', ->
  restrict: 'E'
  replace: true
  template: template
  scope:
    columns: '='
    items: '='
    relation: '='
    model: '@'
    onShow: '&onShowItem'
  link: ($scope, el, attrs) ->
    $scope.sortBy = (column) ->
      sameColumn = $scope.sortingColumn == column
      $scope.sortingColumn = if sameColumn && $scope.reverse
        undefined # Reset sortingColumn when toggling the same column from a reverse
      else
        column

      $scope.reverse = if sameColumn
        !$scope.reverse
      else
        false
