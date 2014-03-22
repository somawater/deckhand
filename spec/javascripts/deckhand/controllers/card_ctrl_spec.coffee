require '../../spec_helper'

describe 'CardCtrl', ->
  scope = null

  beforeEach angular.mock.module 'Deckhand'

  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    $controller('CardCtrl', $scope: scope)

  it "doesn't sort by any column in any table at start", ->
    expect(scope.sortingColumn).toEqual({})

  describe '#sortBy', ->
    column = null

    beforeEach ->
      column = 'sortedColumn'
      scope.sortBy(column, 'table')

    it 'sets sortingColumn to the column specified', ->
      expect(scope.sortingColumn.table).toEqual(column)

    it 'sets reverse to false', ->
      expect(scope.reverse.table).toEqual(false)

    describe 'sorting in a different table', ->
      otherTableColumn = 'otherTableColumn'
      beforeEach ->
        scope.sortBy(otherTableColumn, 'otherTable')

      it "does not change the other table's sorting", ->
        expect(scope.sortingColumn.table).toEqual(column)
        expect(scope.reverse.table).toEqual(false)

      it 'sets sortingColumn to the column specified', ->
        expect(scope.sortingColumn.otherTable).toEqual(otherTableColumn)

      it 'sets reverse to false', ->
        expect(scope.reverse.otherTable).toEqual(false)

    changingTheSortingColumn = ->
      describe 'when changing the sorting column', ->
        anotherColumn = 'anotherColumn'

        beforeEach ->
          scope.sortBy(anotherColumn, 'table')

        it 'sets sortingColumn to the column specified', ->
          expect(scope.sortingColumn.table).toEqual(anotherColumn)

        it 'sets reverse to false', ->
          expect(scope.reverse.table).toEqual(false)

    describe 'when sorting again by that same column', ->
      beforeEach -> scope.sortBy(column, 'table')

      it 'sets sortingColumn to the same column', ->
        expect(scope.sortingColumn.table).toEqual(column)

      it 'sets reverse to true', ->
        expect(scope.reverse.table).toEqual(true)

      describe 'when sorting once again by that same column', ->
        beforeEach -> scope.sortBy(column, 'table')

        it "doesn't sort by any column anymore", ->
          expect(scope.sortingColumn.table).toBeUndefined()

      changingTheSortingColumn()

    changingTheSortingColumn()

