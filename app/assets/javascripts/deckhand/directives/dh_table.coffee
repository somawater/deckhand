fs = require 'fs'
template = fs.readFileSync(__dirname + '/dh_table.html', 'utf8')

Deckhand.app.directive 'dhTable', ->
  link = (scope) ->
    scope.$on 'itemRefreshed', (event, refreshedItem) ->
      for item in scope.items
        if item.id is refreshedItem.id
          angular.extend(item, refreshedItem)
          break

    scope.sortBy = (column) ->
      sameColumn = scope.sortingColumn == column
      scope.sortingColumn = if sameColumn && scope.reverse
        undefined # Reset sortingColumn when toggling the same column from a reverse
      else
        column

      scope.reverse = if sameColumn
        !scope.reverse
      else
        false

  {
    link: link
    restrict: 'E'
    replace: true
    template: template
    scope:
      columns: '='
      items: '='
      relation: '='
      model: '@'
      onShow: '&onShowItem'
  }
