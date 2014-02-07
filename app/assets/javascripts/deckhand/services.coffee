qs = require("querystring")

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

.factory "FieldFormatter", [
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

    {
      format: format
      substitute: substitute
    }
]

.factory "ModelConfig", [->
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

  {
    field: field
    type: type
    tableFields: tableFields
  }
]

.factory 'Cards', [
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
            scrollToCard entry.item

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

.factory 'ModalEditor', [
  'ModelConfig', '$modal', 'Cards', 'AlertService'
  (ModelConfig, $modal, Cards, AlertService) ->

    processResponse = (response) =>
      AlertService.add "success", response.success
      AlertService.add "warning", response.warning
      AlertService.add "info", response.info
      Cards.refresh(item) for item in response.changed

      result = response.result
      Cards.show result._model, result.id if result and result._model

    {
      edit: (item, name) ->
        url = null
        if name
          options = ModelConfig.field(item._model, name).editable
          nested = options.nested
          item = item[name] if nested
        else
          nested = false

        formParams = {type: 'edit', model: item._model}

        if name and not nested # single-field editing
          formParams.edit_fields = [name]
          url = Deckhand.templatePath + "?" + qs.stringify(formParams)

          # this is a workaround for an issue with Angular where it doesn't
          # stringify parameters the same way that Node's querystring does,
          # e.g. http://stackoverflow.com/questions/18318714/angularjs-resource-cannot-pass-array-as-one-of-the-parameters
          formParams["edit_fields[]"] = formParams.edit_fields
          delete formParams.edit_fields
        else # all editable fields at once
          url = Deckhand.templatePath + "?" + qs.stringify(formParams)

        $modal.open(
          templateUrl: url
          controller: "ModalFormCtrl"
          resolve:
            context: ->
              item: item
              title: "edit"
              formParams: formParams
              verb: "update"
        ).result.then processResponse

      processResponse: processResponse
    }
]