Deckhand.app.factory 'Cards', [
  'Model', 'ModelStore', '$rootScope'
  (Model, ModelStore, $rootScope) ->

    cards = []

    scrollToCard = (item) ->
      $rootScope.$broadcast 'showCard', item

    {
      show: (model, id) =>
        entry = ModelStore.find(model, id)
        if entry and entry.card
          scrollToCard entry.item
        else
          Model.get {model: model, id: id}, (item) ->
            entry = ModelStore.register(item)
            entry.card = true
            cards.unshift entry.item

      refresh: (item) ->
        entry = ModelStore.register(item)
        if entry.card
          index = cards.indexOf(entry.item)
          cards.splice index, 1, entry.item # trigger animation

      remove: (item) =>
        cards.splice cards.indexOf(item), 1
        ModelStore.find(item._model, item.id).card = false

      list: -> cards
    }
]
