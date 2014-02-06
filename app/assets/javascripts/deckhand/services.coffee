
# Angular-UI Bootstrap alert service for Angular.js
# https://coderwall.com/p/r_bvhg
Deckhand.app.factory "Search", [
  "$resource"
  ($resource) -> return $resource(Deckhand.searchPath)
]

.factory "AlertService", [
  "$rootScope"
  ($rootScope) ->
    AlertService = undefined
    $rootScope.alerts = []
    add = (type, message) ->
      return if message is `undefined` or not message?
      $rootScope.alerts.push
        type: type
        message: message
        close: -> AlertService.close this

    close = (alert) ->
      @closeIndex $rootScope.alerts.indexOf(alert)

    closeIndex = (index) ->
      $rootScope.alerts.splice index, 1

    clear = ->
      $rootScope.alerts = []

    return AlertService =
      add: add
      close: close
      closeIndex: closeIndex
      clear: clear
]

.factory "Model", [
  "$resource"
  ($resource) ->
    return $resource(Deckhand.showPath, null,
      act:
        method: "PUT"
        url: Deckhand.showPath + "/act"

      getFormData:
        method: "GET"
        url: Deckhand.showPath + "/form"

      update:
        method: "PUT"
        url: Deckhand.showPath
    )
]

.factory "ModelStore", [
  'ModelConfig', '$log'
  (ModelConfig, $log) ->
    window.store = {}
    register = (item) ->
      model = item._model
      id = item.id
      $log.debug "register: #{model} #{id}"

      store[model] or= {}
      store[model][id] or= {card: false}

      entry = store[model][id]
      if entry.item
        extend true, entry.item, item
      else
        entry.item = item

      Object.keys(item).forEach (name) ->
        field = ModelConfig.field(item._model, name)
        return unless field
        if field.table
          item[name].forEach register
        else if field.type is "relation" and item[name] and item[name]._model
          register item[name]

      entry

    find = (model, id) ->
      (if store[model] then store[model][id] else null)

    return (
      find: find
      register: register
    )
]

Deckhand.app.factory "FieldFormatter", [
  "ModelConfig"
  (ModelConfig) ->
    format = (item, attr, modifier) ->
      type = ModelConfig.type(item._model, attr)
      value = undefined
      if type is "relation"
        obj = item[attr]
        value = (if obj then obj._label else "none")
      else
        value = item[attr]
      value = value.replace(/\r\n|\r|\n/g, "<br/>") if modifier is "multiline"
      value

    substitute = (item, attr, string) ->
      value = format(item, attr)
      string.replace ":value", value

    return (
      format: format
      substitute: substitute
    )
]

Deckhand.app.factory "ModelConfig", [->
  field = (model, name, relation) ->
    return null unless Deckhand.models[model]
    if relation
      className = Deckhand.models[model][relation].class_name
      return null unless Deckhand.models[className]
      Deckhand.models[className][name]
    else
      Deckhand.models[model][name]

  type = (model, name) ->
    f = field(model, name)
    (if f then f.type else null)

  tableFields = (model) ->
    modelConfig = Deckhand.models[model]
    return [] unless modelConfig
    Object.keys(modelConfig).filter((name) ->
      modelConfig.hasOwnProperty name
    ).map (name) -> modelConfig[name]

  return (
    field: field
    type: type
    tableFields: tableFields
  )
]