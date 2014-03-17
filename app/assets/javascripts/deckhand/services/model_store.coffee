Deckhand.app.factory "ModelStore", [
  'ModelConfig', '$log'
  (ModelConfig, $log) ->
    store = {}
    register = (item) ->
      model = item._model
      id = item.id

      store[model] or= {}
      store[model][id] or= {card: false}

      entry = store[model][id]
      if entry.item
        $log.debug "register (hit): #{model} #{id}"
        angular.extend entry.item, item
      else
        $log.debug "register (miss): #{model} #{id}"
        entry.item = item

      for name, value of item
        do ->
          field = ModelConfig.field(item._model, name)
          return unless field
          if field.table
            register(nestedItem) for nestedItem in value
          else if field.type is "relation" and value?._model
            register value

      entry

    find = (model, id) ->
      (if store[model] then store[model][id] else null)

    {
      find: find
      register: register
    }
]
