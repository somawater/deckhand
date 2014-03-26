require '../spec_helper'

describe 'dhTable directive', ->
  scope = outerScope = el = null

  beforeEach angular.mock.module 'Deckhand'

  beforeEach inject ($compile, $rootScope) ->
    outerScope = $rootScope.$new()
    outerScope.columns = [
      { name: 'col1', friendlyName: 'Column 1' }
      { name: 'col2', friendlyName: 'Column 2' }
      { name: 'col3', friendlyName: 'Column 3' }
    ]

    outerScope.items = [
      {col1: 'val1', col2: 'val2', col3: 'val3'}
      {col1: 'val4', col2: 'val5', col3: 'val6'}
      {col1: 'val7', col2: 'val8', col3: 'val9'}
    ]
    outerScope.model = 'Model'

    outerScope.showItem = jasmine.createSpy('show')

    html = '''
      <dh-table columns="columns" items="items" model="model" on-show-item="showItem(item)" />
    '''
    el = $compile(html)(outerScope)
    outerScope.$apply()

    scope = el.isolateScope()

  it "doesn't sort by any column at start", ->
    expect(scope.sortingColumn).toBeUndefined()

  describe '#sortBy', ->
    column = null

    beforeEach ->
      column = scope.columns[0]
      scope.sortBy(column)

    it 'sets sortingColumn to the column specified', ->
      expect(scope.sortingColumn).toEqual(column)

    it 'sets reverse to false', ->
      expect(scope.reverse).toEqual(false)

    changingTheSortingColumn = ->
      describe 'when changing the sorting column', ->
        anotherColumn = null

        beforeEach ->
          anotherColumn = scope.columns[1]
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
    it 'shows table rows for each item', ->
      expect(el.find('tbody tr')).toHaveLength(scope.items.length)

    it 'shows the columns specified in the table header', ->
      columnsText = $.map(el.find('thead th'), (e) -> $(e).text().trim())
      columnsText.shift() # Remove first empty header
      columnsNames = scope.columns.map (c) -> c.friendlyName
      expect(columnsText).toEqual(columnsNames)

    it 'shows the columns specified for each row', ->
      headerColumns = el.find('thead th')
      el.find('tbody tr').each (index, el) ->
        expect($(el).find('td')).toHaveLength(headerColumns.length)

  describe 'when clicking the show icon', ->
    beforeEach ->
      el.find('tbody tr:first td:first a').click()

    it 'triggers the show action in the outer scope', ->
      expect(outerScope.showItem).toHaveBeenCalledWith(scope.items[0])

