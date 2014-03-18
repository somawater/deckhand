require './spec_helper'

describe 'ModelStore', ->
  ModelStore = null

  beforeEach angular.mock.module 'Deckhand'

  beforeEach inject (_ModelStore_) ->
    ModelStore = _ModelStore_

  describe '#register', ->
    describe 'with an existing model', ->
      item = updatedItem = null
      beforeEach ->
        item = {
          _model: 'Model',
          id: 1,
          collection: [{a:1}, {b:2}, {c:3}]
        }
        ModelStore.register(item)

        updatedItem = angular.copy(item)
        updatedItem.collection.unshift({d:4})

        ModelStore.register(updatedItem)

      getModel = -> ModelStore.find('Model', 1)

      it 'keeps the same reference to the entry item', ->
        expect(getModel().item).toBe(item) # toBe compares with ===

      it 'updates item collections correctly', ->
        expect(getModel().item.collection).toEqual(updatedItem.collection)
