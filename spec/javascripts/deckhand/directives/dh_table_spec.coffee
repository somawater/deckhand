require '../../spec_helper'

describe 'dhTable directive', ->
  scope = el = null

  beforeEach angular.mock.module 'Deckhand'

  beforeEach inject ($compile, $rootScope) ->
    scope = $rootScope.$new()
    scope.columns =
      table: [
        { name: 'col1', friendlyName: 'Column 1' }
        { name: 'col2', friendlyName: 'Column 2' }
        { name: 'col3', friendlyName: 'Column 3' }
      ]

    scope.items = []
    scope.model = 'Model'

    html = '<dh-table columns="columns" items="items" model="model" />'
    el = $compile(html)(scope)
    scope.$apply()

    scope = el.isolateScope()

  it "doesn't sort by any column at start", ->
    expect(scope.sortingColumn).toBeUndefined()

  describe '#sortBy', ->
    column = null

    beforeEach ->
      column = scope.columns.table[0]
      scope.sortBy(column)

    it 'sets sortingColumn to the column specified', ->
      expect(scope.sortingColumn).toEqual(column)

    it 'sets reverse to false', ->
      expect(scope.reverse).toEqual(false)

    changingTheSortingColumn = ->
      describe 'when changing the sorting column', ->
        anotherColumn = null

        beforeEach ->
          anotherColumn = scope.columns.table[1]
          scope.sortBy(anotherColumn)

        it 'sets sortingColumn to the column specified', ->
          expect(scope.sortingColumn).toEqual(anotherColumn)

        it 'sets reverse to false', ->
          expect(scope.reverse).toEqual(false)

    describe 'when sorting again by that same column', ->
      beforeEach -> scope.sortBy(column, 'table')

      it 'sets sortingColumn to the same column', ->
        expect(scope.sortingColumn).toEqual(column)

      it 'sets reverse to true', ->
        expect(scope.reverse).toEqual(true)

      describe 'when sorting once again by that same column', ->
        beforeEach -> scope.sortBy(column, 'table')

        it "doesn't sort by any column anymore", ->
          expect(scope.sortingColumn).toBeUndefined()

      changingTheSortingColumn()

    changingTheSortingColumn()

  describe 'rendering', ->
    it 'shows table rows for each item'
    it 'shows the columns specified in the table header'
    it 'shows the columns specified for each row'

