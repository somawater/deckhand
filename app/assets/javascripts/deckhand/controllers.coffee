qs = require("querystring")
union = require("./lib/union")

Deckhand.app.controller 'RootCtrl', [
  '$rootScope', 'Model', 'ModelStore'
  ($rootScope, Model, ModelStore) ->
    $rootScope.cards = []
    window.itemEntries = {}

    focusCard = (index) ->
      event = new CustomEvent "focusItem",
        detail:
          index: index

      document.getElementById("cards").dispatchEvent event

    $rootScope.showCard = (model, id) ->
      return unless id
      entry = ModelStore.find(model, id)
      if entry and entry.card
        focusCard $rootScope.cards.indexOf(entry.item)
      else
        Model.get
          model: model
          id: id
        , (item) ->
          entry = ModelStore.register(item)
          entry.card = true
          $rootScope.cards.unshift entry.item
          focusCard 0

    $rootScope.removeCard = (item) ->
      $rootScope.cards.splice $rootScope.cards.indexOf(item), 1
      ModelStore.find(item._model, item.id).card = false

    $rootScope.refreshItem = (newItem) ->
      entry = ModelStore.register(newItem)
      if entry.card
        index = $rootScope.cards.indexOf(entry.item)
        $rootScope.cards.splice index, 1, entry.item # trigger animation

    $rootScope.cardTemplate = (item) ->
      Deckhand.templatePath + "?" + qs.stringify(
        model: item._model
        type: "card"
      )
]

.controller 'SearchCtrl', [
  '$scope', 'Search', 'Model'
  ($scope, Search, Model) ->
    $scope.search = (term) ->
      Search.query(term: term).$promise

    $scope.show = ->
      $scope.showCard $scope.result._model, $scope.result.id
      $scope.result = null
]

.controller 'ModalFormCtrl', [
  '$scope', '$q', '$modalInstance', '$upload', 'Model', 'context', 'Search'
  ($scope, $q, $modalInstance, $upload, Model, context, Search) ->
    $scope.item = context.item
    $scope.form = {}
    $scope.choicesForSelect = {}
    Model.getFormData extend({id: $scope.item.id}, context.formParams), (form) ->
      $scope.title = form.title or context.title
      $scope.prompt = form.prompt
      Object.keys(form.values).forEach (key) ->
        unless key.charAt(0) is "$"
          data = form.values[key]
          $scope.form[key] = data.value
          # FIXME this "form." prefix is weird
          $scope.choicesForSelect["form." + key] = data.choices if data.choices

    $scope.cancel = ->
      $modalInstance.dismiss "cancel"

    $scope.files = {}
    $scope.onFileSelect = ($files, name) ->
      $scope.files[name.replace(/(\.(.*))$/, "[$2]")] = $files[0]

    $scope.submit = ->
      $scope.error = null
      params = undefined
      if context.verb is "update"
        params =
          url: Deckhand.showPath
          method: "PUT"
      else if context.verb is "act"
        params =
          url: Deckhand.showPath + "/act"
          method: "PUT"
      filenames = Object.keys($scope.files)
      files = filenames.map (name) -> $scope.files[name]

      # for typeahead selections, send only the instance's id to the server
      formData = {}
      for key, value of $scope.form
        formData[key] = (if value and value.id then value.id else value)

      extend params,
        fileFormDataName: filenames
        file: files
        data:
          id: $scope.item.id
          non_file_params: extend({form: formData}, context.formParams)

      $upload.upload(params).success((response) ->
        $modalInstance.close response
      ).error (response) ->
        $scope.error = response.error


    $scope.search = (val, model) ->
      Search.query(
        term: val
        model: model
      ).$promise
]

.controller 'CardCtrl', [
  '$scope', '$filter', '$modal', 'Model', 'ModelStore', 'FieldFormatter', 'AlertService', 'ModelConfig'
  ($scope, $filter, $modal, Model, ModelStore, FieldFormatter, AlertService, ModelConfig) ->
    $scope.collapse = {}
    $scope.lazyLoad = {}

    $scope.init = (item) ->
      ModelConfig.tableFields(item._model).forEach (field) ->
        if field.lazy_load
          $scope.collapse[field.name] = true
          $scope.lazyLoad[field.name] = true
        else $scope.collapse[field.name] = true  if field.table and item[field.name].length is 0

    $scope.toggleTable = (name) ->
      if $scope.lazyLoad[name]
        params =
          model: $scope.item._model
          id: $scope.item.id
          eager_load: 1
          fields: name

        Model.get params, (item) ->
          ModelStore.register item
          $scope.lazyLoad[name] = false
          $scope.collapse[name] = false

      else
        $scope.collapse[name] = not $scope.collapse[name]

    $scope.format = FieldFormatter.format
    $scope.substitute = FieldFormatter.substitute

    processResponse = (response) ->
      AlertService.add "success", response.success
      AlertService.add "warning", response.warning
      AlertService.add "info", response.info
      response.changed.forEach (item) -> $scope.refreshItem item

      result = response.result
      $scope.showCard result._model, result.id  if result and result._model

    $scope.act = (item, action, options) ->
      if options.form
        formParams = {model: item._model, act: action, type: "action"}

        url = Deckhand.templatePath + "?" + qs.stringify(formParams)
        modalInstance = $modal.open(
          templateUrl: url
          controller: "ModalFormCtrl"
          resolve:
            context: ->
              item: item
              title: item._label + ": " + $filter("readableMethodName")(action)
              formParams: formParams
              verb: "act"
        )
        modalInstance.result.then processResponse
      else
        options.confirm = "Are you sure?" unless options.hasOwnProperty("confirm")
        if not options.confirm or confirm(options.confirm)
          Model.act
            model: item._model
            id: item.id
            act: action
          , processResponse

    $scope.edit = (name, options) ->
      options = JSON.parse(options)
      options = {} if options is true or not options
      item = (if options.nested then $scope.item[name] else $scope.item)
      formParams = {type: 'edit', model: item._model}

      url = undefined
      if name and not options.nested # single-field editing
        formParams.edit_fields = [name]
        url = Deckhand.templatePath + "?" + qs.stringify(formParams)

        # this is a workaround for an issue with Angular where it doesn't
        # stringify parameters the same way that Node's querystring does,
        # e.g. http://stackoverflow.com/questions/18318714/angularjs-resource-cannot-pass-array-as-one-of-the-parameters
        formParams["edit_fields[]"] = formParams.edit_fields
        delete formParams.edit_fields
      else # all editable fields at once
        url = Deckhand.templatePath + "?" + qs.stringify(formParams)

      modalInstance = $modal.open(
        templateUrl: url
        controller: "ModalFormCtrl"
        resolve:
          context: ->
            item: item
            title: "edit"
            formParams: formParams
            verb: "update"
      )
      modalInstance.result.then processResponse

    $scope.refresh = ->
      Model.get
        model: $scope.item._model
        id: $scope.item.id
      , (newItem) ->
        $scope.refreshItem newItem

]