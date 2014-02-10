qs = require("querystring")
union = require("./lib/union")

Deckhand.app.controller 'CardListCtrl', [
  '$scope', 'Model', 'Cards'
  ($scope, Model, Cards) ->
    $scope.cards = Cards.list()

    $scope.cardTemplate = (item) ->
      Deckhand.templatePath + "?" + qs.stringify(
        model: item._model
        type: "card"
      )
]

.controller 'SearchCtrl', [
  '$scope', 'Search', 'Cards'
  ($scope, Search, Cards) ->
    $scope.search = (term) ->
      Search.query(term: term).$promise

    $scope.select = ->
      $scope.show $scope.result._model, $scope.result.id
      $scope.result = null

    $scope.cards = Cards.list()
    $scope.show = Cards.show
    $scope.remove = Cards.remove
]

.controller 'ModalFormCtrl', [
  '$scope', '$q', '$modalInstance', '$upload', 'Model', 'context', 'Search'
  ($scope, $q, $modalInstance, $upload, Model, context, Search) ->
    $scope.item = context.item
    $scope.form = {}
    $scope.choicesForSelect = {}
    $scope.name = context.name

    Model.getFormData extend({id: $scope.item.id}, context.formParams), (form) ->
      $scope.title = form.title or context.title
      $scope.prompt = form.prompt
      for key, value of form.values
        do ->
          return if key.charAt(0) is "$"
          $scope.form[key] = value.value
          # FIXME this "form." prefix is weird
          $scope.choicesForSelect["form." + key] = value.choices if value.choices

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
  '$scope', '$filter', '$modal', 'Model', 'ModelStore', 'FieldFormatter', 'AlertService', 'ModelConfig', 'Cards', 'ModalEditor'
  ($scope, $filter, $modal, Model, ModelStore, FieldFormatter, AlertService, ModelConfig, Cards, ModalEditor) ->
    $scope.collapse = {}
    $scope.lazyLoad = {}

    $scope.show = Cards.show
    $scope.remove = Cards.remove

    $scope.init = (item) ->
      for field in ModelConfig.tableFields(item._model)
        do ->
          if field.lazy_load
            $scope.collapse[field.name] = true
            $scope.lazyLoad[field.name] = true
          else if field.table and item[field.name].length is 0
            $scope.collapse[field.name] = true

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
        modalInstance.result.then ModalEditor.processResponse
      else
        options.confirm = "Are you sure?" unless options.hasOwnProperty("confirm")
        if not options.confirm or confirm(options.confirm)
          Model.act
            model: item._model
            id: item.id
            act: action
          , ModalEditor.processResponse

    $scope.edit = (name) ->
      ModalEditor.edit item, name

    $scope.refresh = ->
      Model.get
        model: $scope.item._model
        id: $scope.item.id
      , (newItem) ->
        Cards.refresh newItem

]