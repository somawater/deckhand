require '../spec_helper'

describe 'ModelStore', ->
  ModelStore = undefined
  ModelConfig = undefined

  beforeEach angular.mock.module 'Deckhand'

  beforeEach inject (_ModelStore_, _ModelConfig_) ->
    ModelStore = _ModelStore_
    ModelConfig = _ModelConfig_

  getModel = (model, id) -> ModelStore.find(model, id)

  describe '#register', ->
    describe 'with an existing model', ->
      item = updatedItem = undefined
      beforeEach ->
        item = {_model: 'Model', id: 1, collection: [{a:1}, {b:2}, {c:3}]}
        ModelStore.register(item)

        updatedItem = angular.copy(item)
        updatedItem.collection.unshift({d:4})

        ModelStore.register(updatedItem)

      it 'keeps the same reference to the entry item', ->
        expect(getModel('Model', 1).item).toBe(item) # toBe compares with ===

      it 'updates item collections correctly', ->
        expect(getModel('Model', 1).item.collection).toEqual(updatedItem.collection)

    describe 'with a new model', ->
      item = newItem = undefined
      beforeEach ->
        newItem = {_model: 'Model', id: 1, collection: [{a:1}, {b:2}, {c:3}]}

      it 'does not have item in store', ->
        expect(getModel('Model', 1)).toEqual(null)

      it 'stores item', ->
        ModelStore.register(newItem)
        expect(getModel('Model', 1).item.collection).toEqual(newItem.collection)

      it 'references the registered item', ->
        ModelStore.register(newItem)
        expect(getModel('Model', 1).item).toBe(newItem)

    describe 'with nested objects in table field', ->
      parent = firstChild = secondChild = undefined
      beforeEach ->
        firstChild = {_model: 'Child', id: 201, name: 'Child 1'}
        secondChild = {_model: 'Child', id: 202, name: 'Child 2'}
        parent = {_model: 'Parent', id: 101, name: 'Parent', children: [firstChild, secondChild]}

        fieldDefinition = {name: 'children', table: true}
        spyOn(ModelConfig, 'field').and.callFake (model, name) ->
          if model is 'Parent' then fieldDefinition else {}

        ModelStore.register(parent)

      it 'stores parent', ->
        expect(getModel('Parent', 101).item).toBe(parent)

      it 'stores children', ->
        expect(getModel('Child', 201).item).toBe(firstChild)
        expect(getModel('Child', 202).item).toBe(secondChild)

    describe 'with list of objects', ->
      list = first = second = third = undefined
      beforeEach ->
        first = {_model: 'Item', id: 201, name: 'Item 1'}
        second = {_model: 'Item', id: 202, name: 'Item 2'}
        third = {_model: 'Item', id: 203, name: 'Item 3'}
        list = {_model: 'List', id: 'list', name: 'List', items: [first, second, third]}

        ModelStore.register(list)

      it 'stores list', ->
        expect(getModel('List', 'list').item).toBe(list)

      it 'stores list items', ->
        expect(getModel('Item', 201).item).toBe(first)
        expect(getModel('Item', 202).item).toBe(second)
        expect(getModel('Item', 203).item).toBe(third)

    describe 'with relation', ->
      parent = child = undefined
      beforeEach ->
        child = {_model: 'Child', id: 201, name: 'Child 1'}
        parent = {_model: 'Parent', id: 101, name: 'Parent', child: child}

        fieldDefinition = {name: 'child', type: 'relation'}
        spyOn(ModelConfig, 'field').and.callFake (model, name) ->
          if model is 'Parent' then fieldDefinition else {}

        ModelStore.register(parent)

      it 'stores parent', ->
        expect(getModel('Parent', 101).item).toBe(parent)

      it 'stores relation', ->
        expect(getModel('Child', 201).item).toBe(child)
