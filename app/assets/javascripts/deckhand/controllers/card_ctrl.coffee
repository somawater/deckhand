Deckhand.app.controller 'CardCtrl', [
  '$scope', '$filter', '$modal', 'Model', 'ModelStore', 'FieldFormatter', 'AlertService', 'ModelConfig', 'Cards', 'ModalEditor'
  ($scope, $filter, $modal, Model, ModelStore, FieldFormatter, AlertService, ModelConfig, Cards, ModalEditor) ->
    $scope.collapse = {}
    $scope.lazyLoad = {}

    $scope.show = Cards.show
    $scope.remove = Cards.remove

    $scope.sortingColumn = {}
    $scope.reverse = {}

    $scope.init = (item) ->
      return if item.id == 'list'
      for field in ModelConfig.tableFields(item._model)
        do ->
          if field.lazy_load
            $scope.collapse[field.name] = true
            $scope.lazyLoad[field.name] = true
          else if field.table and item[field.name].length is 0
            $scope.collapse[field.name] = true

    $scope.sortBy = (column, table) ->
      sameColumn = $scope.sortingColumn[table] == column
      $scope.sortingColumn[table] = if sameColumn && $scope.reverse[table]
        undefined # Reset sortingColumn when toggling the same column from a reverse
      else
        column
      $scope.reverse[table] = if sameColumn
        if $scope.reverse[table]
          false
        else
          true
      else
        false

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
        ModalEditor.act(action, item)
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
