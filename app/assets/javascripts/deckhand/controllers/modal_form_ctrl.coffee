extend = angular.extend

Deckhand.app.controller 'ModalFormCtrl', [
  '$scope', '$q', '$modalInstance', '$upload', '$sce', 'Model', 'context', 'Search'
  ($scope, $q, $modalInstance, $upload, $sce, Model, context, Search) ->
    $scope.item = context.item
    $scope.itemId = if $scope.item then $scope.item.id else null
    $scope.form = {}
    $scope.choicesForSelect = {}
    $scope.name = context.name

    Model.getFormData extend({id: $scope.itemId}, context.formParams), (form) ->
      $scope.title = form.title or context.title
      $scope.prompt = form.prompt
      for key, value of form.values
        do ->
          return if key.charAt(0) is "$"
          $scope.form[key] = value.value
          # FIXME this "form." prefix is weird
          $scope.choicesForSelect["form." + key] = value.choices if value.choices

          for input_key, input_value of value.inputs
            do ->
              input_key = key + '.' + input_key
              $scope.form[input_key] = input_value.value
              $scope.choicesForSelect["form." + input_key] = input_value.choices if input_value.choices

    $scope.cancel = ->
      $modalInstance.dismiss "cancel"

    $scope.files = {}
    $scope.onFileSelect = ($files, name) ->
      $scope.files[name.replace(/(\.(.*))$/, "[$2]")] = $files[0]

    $scope.submit = ->
      $scope.error = null
      params = switch context.verb
        when "update" then {url: Deckhand.showPath, method: "PUT"}
        when "act" then {url: Deckhand.showPath + "/act", method: "PUT"}
        when "root_act" then {url: Deckhand.showPath + "/root_act", method: "PUT"}

      # for typeahead selections, send only the instance's id to the server
      formData = {}
      for key, value of $scope.form
        formData[key] = (if value and value.id then value.id else value)

      extend params,
        fileFormDataName: (name for name, file of $scope.files)
        file: (file for name, file of $scope.files)
        data:
          id: $scope.itemId
          non_file_params: extend({form: formData}, context.formParams)

      $upload.upload(params).success((response) ->
        $modalInstance.close response
      ).error (response) ->
        $scope.error = $sce.trustAsHtml(response.error)

    $scope.search = (val, model) ->
      Search.query(term: val, model: model).$promise

]
